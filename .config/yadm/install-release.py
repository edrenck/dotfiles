#!/usr/bin/env python3
"""Linux fallbacks when apt has no suitable package. Python standard library only."""
import gzip
import hashlib
import json
import os
import platform
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request
from pathlib import Path

REPOSITORIES = {
    'nvim': 'neovim/neovim', 'eza': 'eza-community/eza',
    'zoxide': 'ajeetdsouza/zoxide', 'starship': 'starship/starship',
    'lazygit': 'jesseduffield/lazygit', 'lazydocker': 'jesseduffield/lazydocker',
    'lf': 'gokcehan/lf', 'gitleaks': 'gitleaks/gitleaks',
    'tree-sitter': 'tree-sitter/tree-sitter', 'ghostty': 'mkasberg/ghostty-ubuntu',
}

def read_url(url):
    request = urllib.request.Request(url, headers={'User-Agent': 'edrenck-dotfiles-bootstrap'})
    with urllib.request.urlopen(request, timeout=120) as response:
        return response.read()

def os_release():
    data = {}
    for line in Path('/etc/os-release').read_text().splitlines():
        if '=' in line and not line.startswith('#'):
            key, value = line.split('=', 1)
            data[key] = value.strip('"\'')
    return data

def ghostty_suffix(info):
    if info.get('ID') == 'debian' or info.get('DEBIAN_CODENAME') in ('trixie', 'forky'):
        version = info.get('DEBIAN_CODENAME', info.get('VERSION_CODENAME', ''))
        if version in ('trixie', 'forky'):
            return version
    version = info.get('UBUNTU_VERSION_ID', info.get('VERSION_ID', ''))
    if info.get('ID') in ('ubuntu', 'pop', 'tuxedo', 'neon', 'elementary') or 'ubuntu' in info.get('ID_LIKE', '').split():
        version = {'noble': '24.04', 'questing': '25.10', 'resolute': '26.04'}.get(info.get('UBUNTU_CODENAME'), version)
        if version in ('24.04', '25.10', '26.04'):
            return version
    raise RuntimeError('No compatible community Ghostty package for this distribution. Use --cli, or install Ghostty manually: https://ghostty.org/docs/install/binary')

def asset_pattern(tool, arch, version, distro=None):
    machine = 'x86_64' if arch == 'amd64' else 'arm64'
    rust = 'x86_64' if arch == 'amd64' else 'aarch64'
    patterns = {
        'nvim': 'nvim-linux-{}.tar.gz'.format(machine),
        'eza': 'eza_{}-unknown-linux-{}.tar.gz'.format(rust, 'musl' if arch == 'amd64' else 'gnu'),
        'zoxide': 'zoxide-{}-{}-unknown-linux-musl.tar.gz'.format(version, rust),
        'starship': 'starship-{}-unknown-linux-musl.tar.gz'.format(rust),
        'lazygit': 'lazygit_{}_linux_{}.tar.gz'.format(version, machine),
        'lazydocker': 'lazydocker_{}_Linux_{}.tar.gz'.format(version, machine),
        'lf': 'lf-linux-{}.tar.gz'.format(arch),
        'gitleaks': 'gitleaks_{}_linux_{}.tar.gz'.format(version, 'x64' if arch == 'amd64' else 'arm64'),
        'tree-sitter': 'tree-sitter-linux-{}.gz'.format('x64' if arch == 'amd64' else 'arm64'),
    }
    if tool == 'ghostty':
        return r'ghostty_[^/]+_{}_{}\.deb'.format(arch, re.escape(distro))
    return re.escape(patterns[tool])

def download_verified(asset, assets):
    payload = read_url(asset['browser_download_url'])
    digest = asset.get('digest') or ''
    expected = digest[7:] if digest.startswith('sha256:') else ''
    if not expected:
        # Some older release assets predate GitHub's digest field.
        for checksum in assets:
            if checksum['name'] == asset['name'] + '.sha256' or 'checksums' in checksum['name'].lower():
                for line in read_url(checksum['browser_download_url']).decode().splitlines():
                    fields = line.split()
                    if fields and re.fullmatch(r'[a-fA-F0-9]{64}', fields[0]):
                        if len(fields) == 1 and checksum['name'] == asset['name'] + '.sha256' or len(fields) >= 2 and fields[-1].lstrip('*') == asset['name']:
                            expected = fields[0].lower()
                            break
                if expected:
                    break
    if not re.fullmatch(r'[a-fA-F0-9]{64}', expected) or hashlib.sha256(payload).hexdigest() != expected.lower():
        raise RuntimeError('Missing or mismatched SHA-256 for ' + asset['name'])
    return payload

def write_executable(path, payload):
    path.parent.mkdir(parents=True, exist_ok=True)
    # Replace a symlink itself, never write through it into a system installation.
    with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as stream:
        temp = Path(stream.name)
        stream.write(payload)
    temp.chmod(0o755)
    temp.replace(path)

def install_archive(tool, archive, destination, data_home):
    if tool == 'tree-sitter':
        write_executable(destination, gzip.decompress(archive.read_bytes()))
        return
    with tarfile.open(archive) as tar:
        if tool != 'nvim':
            members = [m for m in tar.getmembers() if m.isfile() and Path(m.name).name == tool]
            if len(members) != 1:
                raise RuntimeError('Expected one executable for ' + tool)
            write_executable(destination, tar.extractfile(members[0]).read())
            return
        # Neovim needs its runtime tree beside the binary, not just bin/nvim.
        with tempfile.TemporaryDirectory(dir=data_home) as tempdir:
            stage = Path(tempdir)
            for member in tar.getmembers():
                path = stage / member.name
                try:
                    path.resolve().relative_to(stage)
                except ValueError:
                    raise RuntimeError('Unsafe archive path: ' + member.name)
                if not (member.isfile() or member.isdir()):
                    raise RuntimeError('Unsupported archive entry: ' + member.name)
                if member.isdir():
                    path.mkdir(parents=True, exist_ok=True)
                else:
                    path.parent.mkdir(parents=True, exist_ok=True)
                    path.write_bytes(tar.extractfile(member).read())
                    path.chmod(member.mode & 0o777)
            roots = [p for p in stage.iterdir() if (p/'bin/nvim').is_file()]
            if len(roots) != 1:
                raise RuntimeError('Could not identify the Neovim runtime tree')
            installed = data_home / ('nvim-bootstrap-' + hashlib.sha256(archive.read_bytes()).hexdigest()[:12])
            if not installed.exists():
                shutil.move(str(roots[0]), str(installed))
            # Check architecture/glibc compatibility before replacing the active executable.
            subprocess.run([str(installed/'bin/nvim'), '--clean', '--headless', '+q'], check=True)
            link = destination.with_name('.nvim-bootstrap-link')
            link.unlink(missing_ok=True)
            link.symlink_to(installed/'bin/nvim')
            link.replace(destination)

def main():
    tool = sys.argv[1]
    if tool not in REPOSITORIES:
        raise RuntimeError('No apt candidate for {}; enable the standard distro repositories and rerun'.format(tool))
    repo = REPOSITORIES[tool]
    machine = platform.machine()
    arch = {'x86_64': 'amd64', 'aarch64': 'arm64', 'arm64': 'arm64'}.get(machine)
    if arch is None:
        raise RuntimeError('Release fallbacks support only x86_64 and arm64; got ' + machine)
    data = json.loads(read_url('https://api.github.com/repos/' + repo + '/releases/latest'))
    version = data['tag_name'].removeprefix('v')
    pattern = asset_pattern(tool, arch, version, ghostty_suffix(os_release()) if tool == 'ghostty' else None)
    matches = [a for a in data['assets'] if re.fullmatch(pattern, a['name'])]
    if len(matches) != 1:
        raise RuntimeError('No unique compatible asset for {} in {}'.format(tool, data['tag_name']))
    asset = matches[0]
    print('Installing {} {} from {}'.format(tool, data['tag_name'], repo), flush=True)
    payload = download_verified(asset, data['assets'])
    home = Path.home()
    bin_home = home / '.local/bin'
    data_home = Path(os.environ.get('XDG_DATA_HOME', str(home/'.local/share')))
    bin_home.mkdir(parents=True, exist_ok=True)
    data_home.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tempdir:
        archive = Path(tempdir)/asset['name']
        archive.write_bytes(payload)
        if tool == 'ghostty':
            # apt resolves desktop library dependencies for the matching distro build.
            command = [] if os.geteuid() == 0 else ['sudo']
            subprocess.run(command + ['apt-get', 'install', '-y', str(archive)], check=True)
        else:
            install_archive(tool, archive, bin_home/tool, data_home)
    if tool != 'ghostty':
        subprocess.run([str(bin_home/tool), '-version' if tool == 'lf' else '--version'], check=True)

if __name__ == '__main__':
    try:
        main()
    except (RuntimeError, OSError, ValueError, subprocess.CalledProcessError) as error:
        sys.exit('Release install failed: ' + str(error))

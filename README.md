# Platform One Big Bang Cohort

A small repo to aid with the Platform One Big Bang workshops

## Software Installation

### Easy way with `bash` pipe

**Piping into `bash` is dangerous, make sure you understand the risks before copy and pasting code that pipes into `sudo bash`.**

After understanding what the script will do, copy and paste this command into the terminal of your choice:

```bash
curl -sL "https://raw.githubusercontent.com/ghammock/platform_one_big_bang_cohort/main/install_software.sh" | sudo bash
```

### Alternative Installation

Download the file `install_software.sh` to a location of your choice (e.g. `Downloads`).  In a terminal, navigate to the downloaded file location and perform the following steps:

```bash
chmod +x install_software.sh
sudo ./install_software.sh
```

If you forget to run the script with `sudo` or root access, it will prompt you to elevate the script permissions.

### Limitations

The script is currently written to work with `apt`-based Linux distributions (e.g. Ubuntu and Debian).  I'm working on the mods for `dnf`-based distributions (e.g. CentOS and RedHat/RHEL).

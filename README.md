# Platform One Big Bang Cohort

A small repo to aid with the Platform One Big Bang workshops

## Software Installation

### Easy way with `bash` pipe

**Piping into `bash` is dangerous, make sure you understand the risks before copy and pasting code that pipes into `bash`.**

After understanding what the script will do, copy and paste this command into the terminal of your choice:

```bash
curl -sL "https://raw.githubusercontent.com/ghammock/platform_one_big_bang_cohort/main/install_software.sh" | bash
```

The script will prompt for elevated (`sudo`) permissions, install prerequisites, and then install the necessary software.

### Alternative Installation

Download the file `install_software.sh` to a location of your choice (e.g. `Downloads`).  In a terminal, navigate to the downloaded file location and perform the following steps:

```bash
chmod +x install_software.sh
sudo ./install_software.sh
```

If you forget to run the script with `sudo` or root access, it will prompt you to elevate the script permissions.

### Screenshots

#### Piping into bash

![Installation Step 0](assets/img/installation_0.png)

#### Installing the software

![Installing the software](assets/img/installation_1.png)

#### All software installed successfully

![All software installed successfully](assets/img/installation_2.png)

## Limitations

The script is currently written to work with `apt`-based Linux distributions (e.g. Ubuntu and Debian).  I'm working on the mods for `dnf`-based distributions (e.g. CentOS and RedHat/RHEL).

## F.A.Q.s

**Q**. Why does `sshuttle` fail to install?
**A**. I don't know.  This is something to do with the first installation of `python3-pip` where `pip3`
throws an error and refuses to install `sshuttle` (as in the second screenshot).  Re-running the script
seems to fix the error though.

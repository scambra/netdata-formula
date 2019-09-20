# -*- coding: utf-8 -*-
# vim: ft=sls

netdata-uninstall:
  cmd.run:
    - name: /usr/libexec/netdata/netdata-uninstaller.sh --yes --force

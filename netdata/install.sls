# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import netdata with context %}

netdata_requirements:
  pkg.installed:
    - pkgs: {{ (netdata.pkgs + netdata.get('extra_pkgs', []))| json }}

netdata_repo:
  git.latest:
    - name: https://github.com/netdata/netdata.git
    - depth: 1
    - rev: master
    - target: /root/netdata
    - force_reset: True
    - unless: test -f /usr/sbin/netdata

netdata_install:
  cmd.run:
    - cwd: /root/netdata
    - name: ./netdata-installer.sh --dont-wait
    - unless: test -f /usr/sbin/netdata
  require:
    - git: netdata_repo
    - git: netdata_requirements

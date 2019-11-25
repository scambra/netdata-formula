# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import netdata with context %}

netdata_requirements:
  pkg.installed:
    - pkgs: {{ (netdata.pkgs + netdata.get('extra_pkgs', []))| json }}

netdata_install:
  cmd.run:
    - name: bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait {{ netdata.get('install', {}).get('args', '') }}
    - unless: test -f /usr/sbin/netdata
  require:
    - git: netdata_requirements

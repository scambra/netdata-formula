# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config' %}
{%- from tplroot ~ "/map.jinja" import netdata with context %}

include:
  - {{ sls_config_file }}

netdata-service:
  service.running:
    - name: {{ netdata.service.name }}
    - enable: True
    - require:
      - sls: {{ sls_config_file }}

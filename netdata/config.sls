# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_install = tplroot ~ '.install' %}
{%- from tplroot ~ "/map.jinja" import netdata with context %}

include:
  - {{ sls_install }}

{%- set custom_config = False %}
{%- set default_config = netdata.default_config %}
{%- for name, config_data in netdata.configs.items() %}
{%-   if 'config' in config_data %}
{%-     if name == 'stream' %}
{%-       if config_data.get('generate_api_key', False) and '[api_key]' in config_data.config %}
{%-         set api_key = salt['mine.get'](grains['id'], 'netdata_api_key').get(grains['id'], None) %}
{%-         if not api_key %}
{%-           set api_key = salt['cmd.run']('cat /proc/sys/kernel/random/uuid')['local'] %}
{%-           do salt['mine.send']('netdata_api_key', "echo '" + api_key + "'", mine_function='cmd.run') %}
{%-         endif %}
{%-         do config_data.config.update({api_key: config_data.config.pop('[api_key]')}) %}
{%-       endif %}
{%-       if config_data.get('get_api_key_from', False) and 'stream' in config_data.config %}
{%-         set api_key = salt['mine.get'](config_data.get_api_key_from, 'netdata_api_key') %}
{%-         do config_data.config.stream.update({'api key': api_key.get(config_data.get_api_key_from, '')}) %}
{%-       endif %}
{%-     endif %}

{%-     set custom_config = True %}

{{ default_config.dir }}/{{ config_data.get('file', name + '.conf') }}:
  file.managed:
    - source: salt://netdata/files/{{ config_data.get('source', 'netdata.conf') }}
    - mode: {{ config_data.get('mode', default_config.mode) }}
    - user: {{ config_data.get('user', default_config.user) }}
    - group: {{ config_data.get('group', default_config.group) }}
    - makedirs: True
    - template: jinja
    - context:
        config: {{ config_data.config | json }}
    - require:
      - sls: {{ sls_install }}
    - watch_in:
      - service: {{ netdata.service.name }}
{%-   endif %}
{%- endfor %}

{% if not custom_config %}
netdata_default_config:
    test.show_notification:
        - text: "Using default config."
{% endif %}

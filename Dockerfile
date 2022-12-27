FROM kong:3.1.1-alpine
USER root
COPY . /custom_plugin/log-body
RUN cd /custom_plugin/log-body && luarocks make *.rockspec
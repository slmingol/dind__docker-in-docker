FROM docker:29.9.0-dind
COPY dockerd-entrypoint.sh /usr/local/bin/
ENV PATH=$PATH:/custom/dir/bin
ENTRYPOINT ["dockerd-entrypoint.sh"]

FROM docker:29.8.2-dind
COPY dockerd-entrypoint.sh /usr/local/bin/
ENV PATH=$PATH:/custom/dir/bin
ENTRYPOINT ["dockerd-entrypoint.sh"]

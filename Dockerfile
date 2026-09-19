FROM docker:20.10.24-dind
COPY dockerd-entrypoint.sh /usr/local/bin/
ENV PATH=$PATH:/custom/dir/bin
ENTRYPOINT ["dockerd-entrypoint.sh"]

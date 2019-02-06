FROM alpine:3.9

RUN apk --update upgrade \
#     && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
#		 && apk update \
     && apk --update add --no-cache sudo python3 openssl ca-certificates \
     sshpass openssh-client rsync curl \
     && apk --upgrade add --no-cache --virtual build-dependencies \
		 build-base python3-dev libffi-dev openssl-dev \
		 && python3 -m ensurepip \
		 && rm -r /usr/lib/python*/ensurepip \
		 && pip3 install --upgrade pip setuptools \
		 && pip3 install --upgrade ansible awscli six cryptography boto3 botocore boto \
		 && apk del build-dependencies build-base python3-dev libffi-dev openssl-dev \
		 && rm -fr /var/cache/apk/* \
		 && mkdir -p /etc/ansible \
		 && echo 'localhost' > /etc/ansible/hosts \
		 && curl https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py -s -o /etc/ansible/ec2.py \
		 && curl https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.ini -s -o /etc/ansible/ec2.ini \
		 && chmod +x /etc/ansible/ec2.py
RUN if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi \
    && if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi \
		&& rm -r /root/.cache

ENV ANSIBLE_INVENTORY=/etc/ansible/ec2.py
ENV EC2_INI_PATH=/etc/ansible/ec2.ini

CMD [ "ansible-playbook", "--version" ]

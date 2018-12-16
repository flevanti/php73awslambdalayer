# I use both `cd` and `WORKDIR` to make sure the directory exists 
# before using it and I'm not doing something stupid
# WORKDIR create a directory if missing and I don't trust my own code 😄

# Instuctions initially obtained from here: https://aws.amazon.com/blogs/apn/aws-lambda-custom-runtime-for-php-a-practical-example/

# This is the current AMI used for lambda instances
FROM amazonlinux:2017.03.1.20170812

# Update packages and install needed compilation dependencies
RUN yum update -y
RUN yum install autoconf bison gcc gcc-c++ libcurl-devel libxml2-devel -y


# Compile OpenSSL v1.0.1 from source, as Amazon Linux uses a newer version than the Lambda Execution Environment, which
# would otherwise produce an incompatible binary.
RUN curl -sL http://www.openssl.org/source/openssl-1.0.1k.tar.gz | tar -xvz
RUN cd openssl-1.0.1k
WORKDIR openssl-1.0.1k
RUN ./config
RUN make
RUN make install

# Download the PHP 7.3.0 source
RUN mkdir /php-7-bin
RUN cd /
WORKDIR /
RUN curl -sL https://github.com/php/php-src/archive/php-7.3.0.tar.gz | tar -xvz
RUN cd php-src-php-7.3.0
WORKDIR php-src-php-7.3.0

# Compile PHP 7.3.0 with OpenSSL 1.0.1 support, and install to /home/ec2-user/php-7-bin
RUN ./buildconf --force
RUN yum install wget nano -y
# download the pear install manually and put it in the right folder
# the operation was failing if performed by the compile process with a SSL certificate error
# I tested it on EC2 instance and it was working fine
RUN wget https://pear.php.net/install-pear-nozlib.phar
RUN mv install-pear-nozlib.phar /php-src-php-7.3.0/pear/
RUN ./configure --prefix=/php-7-bin/ --with-openssl=/usr/local/ssl --with-curl --with-zlib
RUN make install

FROM rhel7

# This image provides a Common Lisp environment based on QuickLisp and
# that you can use to run your Common Lisp applications.

MAINTAINER Anthony Green <green@redhat.com>

EXPOSE 8080

ENV LISP_VERSION 1.0

LABEL io.k8s.description="Platform for building and running Common Lisp applications" \
      io.k8s.display-name="Common Lisp" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,cl,lisp,sbcl"

RUN yum install -y \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y sbcl && \
    yum clean all -y

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
COPY ./contrib/ /opt/app-root

ENV HOME /opt/app-root
RUN chown -R 1001:0 /opt/app-root
USER 1001
WORKDIR /opt/app-root
RUN wget http://beta.quicklisp.org/quicklisp.lisp
ADD install.lisp /opt/app-root/install.lisp
RUN sbcl --non-interactive --load install.lisp

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage

Ruby Docker image
=================

This repository contains the source for building Ruby as a reproducible Docker image using
[source-to-image](https://github.com/openshift/source-to-image).
This builder image is based on Fedora 26, although as modules  become available, it will move to modules.
The resulting image can be run using [Docker](http://docker.io).
This is a port from [Software Collections](https://github.com/sclorg/s2i-ruby-container)

Usage
---------------------
To build a simple [ruby-sample-app](https://github.com/container-images/ruby/tree/master/test/puma-test-app) application
using standalone [S2I](https://github.com/openshift/source-to-image) and then run the
resulting image with [Docker](http://docker.io) execute:

    ```
    $ s2i build https://github.com/container-images/ruby.git --context-dir=test/puma-test-app/ modularitycontainers/ruby-24 ruby-sample-app
    $ docker run -p 8080:8080 ruby-sample-app

**Accessing the application:**
```
$ curl 127.0.0.1:8080
```


Repository organization
------------------------

* **Dockerfile**

    Fedora 26 based Dockerfile.

* **`s2i/bin/`**

    This folder contains scripts that are run by [S2I](https://github.com/openshift/source-to-image):

    *   **assemble**

        Used to install the sources into the location where the application
        will be run and prepare the application for deployment (eg. installing
        modules using bundler, etc.)

    *   **run**

        This script is responsible for running the application by using the
        application web server.

    *   **usage***

        This script prints the usage of this image.

* **`test/`**

    This folder contains a [S2I](https://github.com/openshift/source-to-image)
    test framework with a simple Rack server.

    * **`puma-test-app/`**

        Simple Puma web server used for testing purposes by the [S2I](https://github.com/openshift/source-to-image) test framework.

    * **`rack-test-app/`**

        Simple Rack web server used for testing purposes by the [S2I](https://github.com/openshift/source-to-image) test framework.

    * **run**

        Script that runs the [S2I](https://github.com/openshift/source-to-image) test framework.


Environment variables
---------------------

To set these environment variables, you can place them as a key value pair into a `.sti/environment`
file inside your source code repository.

* **RACK_ENV**

    This variable specifies the environment where the Ruby application will be deployed (unless overwritten) - `production`, `development`, `test`.
    Each level has different behaviors in terms of logging verbosity, error pages, ruby gem installation, etc.

    **Note**: Application assets will be compiled only if the `RACK_ENV` is set to `production`

* **DISABLE_ASSET_COMPILATION**

    This variable set to `true` indicates that the asset compilation process will be skipped. Since this only takes place
    when the application is run in the `production` environment, it should only be used when assets are already compiled.

* **PUMA_MIN_THREADS**, **PUMA_MAX_THREADS**

    These variables indicate the minimum and maximum threads that will be available in [Puma](https://github.com/puma/puma)'s thread pool.

* **PUMA_WORKERS**

    This variable indicate the number of worker processes that will be launched. See documentation on Puma's [clustered mode](https://github.com/puma/puma#clustered-mode).

* **RUBYGEM_MIRROR**

    Set this variable to use a custom RubyGems mirror URL to download required gem packages during build process.

Hot deploy
---------------------
In order to dynamically pick up changes made in your application source code, you need to make following steps:

*  **For Ruby on Rails applications**

    Run the built Rails image with the `RAILS_ENV=development` environment variable passed to the [Docker](http://docker.io) `-e` run flag:
    ```
    $ docker run -e RAILS_ENV=development -p 8080:8080 rails-app
    ```
*  **For other types of Ruby applications (Sinatra, Padrino, etc.)**

    Your application needs to be built with one of gems that reloads the server every time changes in source code are done inside the running container. Those gems are:
    * [Shotgun](https://github.com/rtomayko/shotgun)
    * [Rerun](https://github.com/alexch/rerun)
    * [Rack-livereload](https://github.com/johnbintz/rack-livereload)

    Please note that in order to be able to run your application in development mode, you need to modify the [S2I run script](https://github.com/openshift/source-to-image#anatomy-of-a-builder-image), so the web server is launched by the chosen gem, which checks for changes in the source code.

    After you built your application image with your version of [S2I run script](https://github.com/openshift/source-to-image#anatomy-of-a-builder-image), run the image with the RACK_ENV=development environment variable passed to the [Docker](http://docker.io) -e run flag:
    ```
    $ docker run -e RACK_ENV=development -p 8080:8080 sinatra-app
    ```

To change your source code in running container, use Docker's [exec](http://docker.io) command:
```
docker exec -it <CONTAINER_ID> /bin/bash
```

After you [Docker exec](http://docker.io) into the running container, your current
directory is set to `/opt/app-root/src`, where the source code is located.

Performance tuning
---------------------
You can tune the number of threads per worker using the
`PUMA_MIN_THREADS` and `PUMA_MAX_THREADS` environment variables.
Additionally, the number of worker processes is determined by the number of CPU
cores that the container has available, as recommended by
[Puma](https://github.com/puma/puma)'s documentation. This is determined using
the cgroup [cpusets](https://www.kernel.org/doc/Documentation/cgroup-v1/cpusets.txt)
subsystem. You can specify the cores that the container is allowed to use by passing
the `--cpuset-cpus` parameter to the [Docker](http://docker.io) run command:
```
$ docker run -e PUMA_MAX_THREADS=32 --cpuset-cpus='0-2,3,5' -p 8080:8080 sinatra-app
```
The number of workers is also limited by the memory limit that is enforced using
cgroups. The builder image assumes that you will need 50 MiB as a base and
another 15 MiB for every worker process plus 128 KiB for each thread. Note that
each worker has its own threads, so the total memory required for the whole
container is computed using the following formula:

```
50 + 15 * WORKERS + 0.125 * WORKERS * PUMA_MAX_THREADS
```
You can specify a memory limit using the `--memory` flag:
```
$ docker run -e PUMA_MAX_THREADS=32 --memory=300m -p 8080:8080 sinatra-app
```
If memory is more limiting then the number of available cores, the number of
workers is scaled down accordingly to fit the above formula. The number of
workers can also be set explicitly by setting `PUMA_WORKERS`.

Running in Openshift
---------------------
You can use also this image in Openshift using the openshift-template.yml in this repository. 

Login
```
$ oc login -u developer
```

Create new project
```
$ oc new-project sample-project
```

Create template from YAML file
```
$ oc create -f openshift-template.yaml
```

Create new application (ruby-fedora is template created in previous step)
```
$ oc new-app ruby-fedora -p APP_NAME=<name> -p SOURCE_REPOSITORY=<your-github-repository>
```
For example:
```
$ oc new-app ruby-fedora -p APP_NAME=my-app -p SOURCE_REPOSITORY=https://github.com/kosciCZ/ruby-ex.git
```
Check if everything is ok
```
$ oc logs -f bc/my-app


# Testing

There are two test suites included in this repository. One using MTF and the other uses conu.

To run the conu based test suite, you need to follow these steps:

 1. [Install conu](http://conu.readthedocs.io/en/latest/installation.html).
 2. `sudo dnf install -y python3-pytest`
 3. `make check`

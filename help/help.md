% RUBY (1) Container Image Pages
% Jan Koscielniak
% September 20, 2017

# NAME
Ruby - A dynamic, open source programming language with a focus on simplicity and productivity.

# DESCRIPTION
This is a Ruby 2.4 s2i builder image.

# USAGE
This is image can be run both with standalone s2i tool, or in Openshift. 

To build your application with s2i, run:

    # s2i <SOURCE_GIT_REPOSITORY> modularitycontainers/ruby-24 <APP_NAME> 

To run the resulting container with your application, run:
	
	# docker run -p 8080:8080 <APP_NAME>

To run this image in Openshift, please obtain template from https://github.com/container-images/ruby and then run:

	# oc new-project <PROJECT_NAME>
	# oc new-app <TEMPLATE_FILE> -p APP_NAME=<APP_NAME> -p SOURCE_REPOSITORY=<SOURCE_REPOSITORY>

# ENVIRONMENT VARIABLES
RACK_ENV
    This variable specifies the environment where the Ruby application will be deployed (unless overwritten) - `production`, `development`, `test`.
    Each level has different behaviors in terms of logging verbosity, error pages, ruby gem installation, etc.
	Note: Application assets will be compiled only if the `RACK_ENV` is set to `production`

DISABLE_ASSET_COMPILATION
    This variable set to `true` indicates that the asset compilation process will be skipped. Since this only takes place
    when the application is run in the `production` environment, it should only be used when assets are already compiled.

PUMA_MIN_THREADS, PUMA_MAX_THREADS
    These variables indicate the minimum and maximum threads that will be available in [Puma](https://github.com/puma/puma)'s thread pool.

PUMA_WORKERS
    This variable indicate the number of worker processes that will be launched. See documentation on Puma's [clustered mode](https://github.com/puma/puma#clustered-mode).

RUBYGEM_MIRROR
    Set this variable to use a custom RubyGems mirror URL to download required gem packages during build process.

RAILS_ENV
	Set this variable to `development` to enable hot deploy for Ruby on Rails applications. For other types of applications, please refer to [Github repository](https://github.com/container-images/ruby)

# SECURITY IMPLICATIONS
-p 8080:8080
    Opens container port 8080 and maps it to the same port on the Host to display Puma frontend

--memory=300m
    Can be used to limit memory that application uses (mainly puma)

--cpuset-cpus='0-2,3,5'
	Can be used to select which CPU cores can application use

# HISTORY
Similar to a Changelog of sorts which can be as detailed as the maintainer wishes.

# SEE ALSO
A github repository with source of this image: https://github.com/container-images/ruby
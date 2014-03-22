This repository provides a template for creating Dockerized Drupal projects.

Docker Images
-------------
The following is the order of consequetive Docker images according to their
dependencies on one another, as per each image's corresponding `FROM` statement:
* `base`: installs general dependnecies, typically only needs to be build once
  per project.
* `server`: installs all configuration files.
* `data`: populates data for MySQL and/or cached Solr index.
* `drupal`: adds the site and performs required adjustments. The Drupal project
  repository can be fetched like all other assets, see [Assets](#assets). The
  `Dockerfile` for this image will live not in the `project` directory but in
  this repo's root to allow for non-dockerized projects to be deployed using
  this repo.

Templating System
-----------------
Templating is kept at a very minimal level and is done using the `envsubst`
utility. For the behavior of `envsubst` and its proper usage, see [Envsubst usage](#envsubst-usage).
The following similar, but separate templating use cases are supported:

### Initializing Dockerfiles
The repo comes with no `Dockerfile`s but `Dockerfile.tpl` files containing
variable references to `$_conf_prj_name`.  The `make initialize_dockerfiles`
target goes through the `base`, `server`, `data`, and root directories and only
if a `Dockerfile` does not exist creates a `Dockerfile` from `Dockerfile.tpl` by
substituting all references to `$_conf_prj_name` with the value of Make variable
`project`. The intended use case is to invoke this Make target once when
initializing a project repo and then commiting the `Dockerfiles` to keep the
image build process consistent and trackable. Note that the only variable that
is respected in `Dockerfile.tpl` files is the project name variable.  Other
variables can be introduced by changing the `Makefile` and making appropriate
changes to the `prepare_assets` script, but further templating of `Dockerfile`
is probably not a good idea.

### Generating configuration files
All configuration files, typically to be found in `server/conf` have the `.tpl`
extension and reference a variety of configuration variables.  Dockerfiles use
`subst_conf` to template these configuration files.  `subst_conf` is a wrapper
around `envsubst` allowing for clean batch variable substitutions; see
[subst_conf Usage](#subst_conf) and [envsubst Usage](#envsubst) for
the reason this wrapper is needed.  The definitions for variables used in each
configuration file is passed at execution time (that is in corresponding
`Dockerfile`s) to `subst_conf`.  However, it is desirable to keep all
configuration variables in one file, currently `server/conf/build_config.sh`.

Note that although the variable name `$_conf_prj_name` follows the format
expected by `subst_conf`, it only does so for consistency. For initializing
`Dockerfile`s, `subst_conf` is not used (since we are dealing with an individual
variable a simple invocation of `envsubst` suffices).

Image Directory Structure
-------------------------
Images contains two important directories whose paths are hardcoded as they
rarely require modification:
* `/var/shared/sites/` which is the directory in which the Drupal project will
  be `ADD`ed. For example, the document root of Drupal could be
  `/var/shared/sites/[project]/site`.
* `/var/shared/build` which is the directory where all build scripts,
  configuration files and assets are `ADD`ed. All scripts will end up in
  `/var/shared/build/scripts`, all assets in `/var/shared/build/assets`, and all
  configuration files (and/or configuration templates) in
  `/var/shared/build/conf`.

### Scripts
Each directory corresponding to an image can place all its executable scripts
in a `scripts` subdirectory. This subdirectory will be added to
`/var/shared/build/scripts/[image]`. Typical usage is to invoke
`symlink_all_scripts` (installed in `base`) right after `ADD`ing the above which
will mark all contents of the `/var/shared/build/scripts/[image]` directory as
executable and force creates symlinks to each in `/usr/local/bin`. This allows
subsequent layers to override the global (via `PATH`) program path without
having to throw out the actual contents of the lower image's script.

### Assets
Each directory corresponding to an image can place all its assets, which are
typically large data files such as database dumps, in an `assets` directory.
This subdirectory ends up at `/var/shared/build/assets/[image]` in the image.
The assets are typically loaded via the `prepare` make target which uses the
`prepare_assets` script to pull in various assets that are not intended to be
commited in the repository.

Helper Programs
---------------

### `envsubst`

`envsubst` is part of the GNU `gettext` package. Note that this package is
typically stripped from Docker base images and has to be installed in images
(this is done in the `server` image). `envsubst` operates (in its 'normal mode
of operation' which is the only way it is used in this repo) by reading lines
from standard input and replacing all instances of shell variable references by
their corresponding values from defined environment variables. For example:
```bash
echo '$config_file should be updated' | config_file=/etc/config envsubst
# /etc/config should be updated
```
Note that in the above usage, if an additional variable is referenced it will be
replaced by an empty string:
```bash
echo '$config_file should be updated by $admin_user.' | config_file=/etc/config envsubst
# /etc/config should be updated by .
```
This behavior is generally undesirable in our use cases of templating
configuration files. To fix this behavior an argument containing a list of
variables can be passed to `envsubst`:
```bash
echo '$config_file should be updated by $admin_user.' | config_file=/etc/config envsubst '$config_file'
# /etc/config should be updated by $admin_user.
```
The `envsubst` manpage refers to this positional argument as the `SHELL-FORMAT`
argument for some reason! Also note that the only two forms of variable
references that are respected by `envsubst` are `$variable` and `${variable}`
(the latter being more desirable to avoid unintended conflicts). All other valid
forms of bash variable expansions, e.g. `${variable:-default}` and the like, are
not respected by `envsubst`.

### `subst_conf`
`subst_conf` is a wrapper around `envsubst` that allows batch substitution of
configuration variables in configuration files with variable definitions
residing in a simple bash script. `subst_conf` expects exactly one positional
argument, namely the variable definition script, and behaves as follows:
```bash
# build_config.sh

_conf_prj_name=MyProject
_conf_prj_root=/var/shared/sites/${_conf_prj_name}
_conf_solr_home=${_conf_prj_root}/solr
```

```xml
<!--  context.xml.tpl -->
<Context docBase="/opt/solr/solr_${_conf_solr_version}.war" debug="0" crossContext="true">
  <Environment
    name="solr/home"
    type="java.lang.String"
    value="${_conf_solr_home}"
    override="true"
  />
  <Valve
    className="org.apache.catalina.valves.AccessLogValve"
    prefix = "${_conf_prj_name}_"
    suffix = ".log"
    pattern = "common"
  />
</Context>
```

```bash
subst_conf build_config.sh < context.xml.tpl
# <Context docBase="/opt/solr/solr_${_conf_solr_version}.war" debug="0" crossContext="true">
#   <Environment
#     name="solr/home"
#     type="java.lang.String"
#     value="/var/shared/sites/MyProject/solr"
#     override="true"
#   />
#   <Valve
#     className="org.apache.catalina.valves.AccessLogValve"
#     prefix = "MyProject_"
#     suffix = ".log"
#     pattern = "common"
#   />
# </Context>
```

Note that `subst_conf` only respects variables of the form `_conf_*` to avoid
unintended substitutions, and leaves undefined variable references intact.

### `supervisor_drupal_helpers.sh`
This script is intended to be `source`d by other scripts that require certain
services to be running in a provisioning step, e.g. loading a database dump. The
main functions it defines are `supervisor_service_up` and
`supervisor_services_done` which can be used as follows:

```bash
#!/bin/bash

source /usr/local/bin/supervisor_drupal_helpers.sh

db_dump="$1"

supervisor_service_up mysql
zcat "$db_dump" | $drush sqlc
supervisor_services_done
```

Note that `supervisor_services_done` only stops MySQL (in this case) if it was
`supervisor_service_up` that started MySQL. This means all provisioning scripts
can be executed seemlessly in a running container with running services as well
as in Dockerfile `RUN` statements.

The script also provides shothands like `$drush` (which expands to `drush
--root=/path/to/drupal/root/`) and others according to the configuration in
`server/conf/build_config.sh`.

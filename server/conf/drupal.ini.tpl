; enabling PHP extensions and configuring PHP for development environment
extension=apc.so
apc.shm_size=64M

extension=xhprof.so
xhprof.output_dir=/tmp

extension=uploadprogress.so
memory_limit=2048M

display_errors=On
error_reporting= E_ALL | E_STRICT

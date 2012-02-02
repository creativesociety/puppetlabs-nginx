# define: nginx::resource::rewrite
#
# This definition creates a new rewrite entry within a virtual host location
#
# Parameters:
#   [*ensure*]             - Enables or disables the specified rewrite (present|absent)
#   [*vhost*]              - Specify the vhost for this rewrite rule
#   [*ssl*]                - Apply to ssl vhost?
#   [*location*]           - Specifies the location associated with the rewrite, if not vhost-wide
#                            for the entire vhost
#   [*regex*]              - regular expression to match
#   [*replacement*]        - replacement expression
#   [*condition*]          - wrap rewrite in an if conditional
#   [*order*]              - string used to order rewrites
#   [*flag*]               - (last, break, redirect, permanent)
#   [*description*]        - optional description
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  nginx::resource::rewrite { 'test2.local-bob-redirect-to-ssl':
#    ensure      => present,
#    vhost       => 'test2.local',
#    ssl         => false,
#    location    => 'default'
#    regex       => '^/(.*)$',
#    replacement => 'https://$host/$1',
#    condition   => '$http_host !~ :\d+',
#    flag        => 'permanent'
#  }
define nginx::resource::rewrite(
  $ensure = present,
  $vhost,
  $location = undef,
  $condition = undef,
  $order = '10',
  $regex,
  $replacement,
  $flag,
  $ssl = false,
  $description = undef
) {
  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Class['nginx::service'],
  }

  ## Shared Variables
  $ensure_real = $ensure ? {
    'absent' => absent,
    default  => file,
  }

  $location_real = $location ? {
    'default' => "${vhost}-default",
    '/'       => "${vhost}-default",
    undef     => undef,
    default   => $location
  }

  $content_real = template('nginx/vhost/vhost_rewrite.erb')

  ## rewrite fragment
  if $location_real {
    file {"${nginx::config::nx_temp_dir}/nginx.d/${vhost}-500-${location_real}-200-rewrite-${order}-${name}":
      ensure  => $ensure_real,
      content => $content_real,
    }
  } else {
    file {"${nginx::config::nx_temp_dir}/nginx.d/${vhost}-220-rewrite-${order}-${name}":
      ensure  => $ensure_real,
      content => $content_real,
    }
  }


  ## Only create SSL Specific fragment if $ssl is true.
  if $ssl {
    if $location_real {
      file {"${nginx::config::nx_temp_dir}/nginx.d/${vhost}-800-${location_real}-200-rewrite-${order}-${name}-ssl":
        ensure  => $ensure_real,
        content => $content_real,
      }
    } else {
      file {"${nginx::config::nx_temp_dir}/nginx.d/${vhost}-720-rewrite-${order}-${name}-ssl":
        ensure  => $ensure_real,
        content => $content_real,
      }
    }
  }
}

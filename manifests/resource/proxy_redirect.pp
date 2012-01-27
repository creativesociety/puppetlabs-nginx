# define: nginx::resource::proxy_redirect
#
# This definition creates a new proxy redirect entry within a virtual host location
#
# Parameters:
#   [*ensure*]             - Enables or disables the specified location (present|absent)
#   [*vhost*]              - Specify the vhost for this proxy_redirect entry
#   [*ssl*]                - Apply to ssl vhost?
#   [*location*]           - Specifies the location associated proxy_redirect
#   [*from*]               - rewrite from
#   [*to*]                 - rewrite to
#   [*option*]             - Reserved for future use
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  nginx::resource::proxy_redirect { 'test2.local-bob-redirect':
#    ensure   => present,
#    vhost    => 'test2.local',
#    location => '/bob',
#    from     => 'http://test1.local',
#    to       => '$scheme://$http_host/';
#  }
define nginx::resource::proxy_redirect(
  $ensure = present,
  $vhost,
  $location,
  $from,
  $to,
  $ssl = false
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

  $content_real = template('nginx/vhost/vhost_location_proxy_redirect.erb')

  ## Create stubs for vHost File Fragment Pattern
  file {"${nginx::config::nx_temp_dir}/nginx.d/${vhost}-550-${location}-${name}":
    ensure  => $ensure_real,
    content => $content_real,
  }

  ## Only create SSL Specific locations if $ssl is true.
  if ($ssl) {
    file {"${nginx::config::nx_temp_dir}/nginx.d/${vhost}-850-${location}-${name}-ssl":
      ensure  => $ensure_real,
      content => $content_real,
    }
  }
}


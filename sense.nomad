job "sense" {
  datacenters = ["dc1"]
  type = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    progress_deadline = "10m"
    auto_revert = false
    canary = 0
  }
  group "controller" {
    count = 1
    network {
      port "api" {
        to = 8000
      }
    }

    service {
      name     = "sense-controller"
      tags     = ["sense", "controller"]
      port     = "api"
      provider = "consul"

      check {
        name     = "alive"
        type     = "http"
        interval = "10s"
        timeout  = "2s"
      }

    }

    restart {
      attempts = 2
      interval = "1m"
      delay = "15s"
      mode = "delay"
    }
    ephemeral_disk {
      sticky = true
      migrate = true
      size = 10
    }

    task "api" {
      driver = "raw_exec"

      config {
        image = "redis:7"
        ports = ["db"]

        # The "auth_soft_fail" configuration instructs Nomad to try public
        # repositories if the task fails to authenticate when pulling images
        # and the Docker driver has an "auth" configuration block.
        auth_soft_fail = true
      }

      # The "artifact" block instructs Nomad to download an artifact from a
      # remote source prior to starting the task. This provides a convenient
      # mechanism for downloading configuration files or data needed to run the
      # task. It is possible to specify the "artifact" block multiple times to
      # download multiple artifacts.
      #
      # For more information and examples on the "artifact" block, please see
      # the online documentation at:
      #
      #     https://developer.hashicorp.com/nomad/docs/job-specification/artifact
      #
      # artifact {
      #   source = "http://foo.com/artifact.tar.gz"
      #   options {
      #     checksum = "md5:c4aa853ad2215426eb7d70a21922e794"
      #   }
      # }

      # The "logs" block instructs the Nomad client on how many log files and
      # the maximum size of those logs files to retain. Logging is enabled by
      # default, but the "logs" block allows for finer-grained control over
      # the log rotation and storage configuration.
      #
      # For more information and examples on the "logs" block, please see
      # the online documentation at:
      #
      #     https://developer.hashicorp.com/nomad/docs/job-specification/logs
      #
      # logs {
      #   max_files     = 10
      #   max_file_size = 15
      # }

      # The "identity" block instructs Nomad to expose the task's workload
      # identity token as an environment variable and in the file
      # secrets/nomad_token.
      identity {
        env  = true
        file = true
      }

      # The "resources" block describes the requirements a task needs to
      # execute. Resource requirements include memory, cpu, and more.
      # This ensures the task will execute on a machine that contains enough
      # resource capacity.
      #
      # For more information and examples on the "resources" block, please see
      # the online documentation at:
      #
      #     https://developer.hashicorp.com/nomad/docs/job-specification/resources
      #
      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
      }


      # The "template" block instructs Nomad to manage a template, such as
      # a configuration file or script. This template can optionally pull data
      # from Consul or Vault to populate runtime configuration data.
      #
      # For more information and examples on the "template" block, please see
      # the online documentation at:
      #
      #     https://developer.hashicorp.com/nomad/docs/job-specification/template
      #
      # template {
      #   data          = "---\nkey: {{ key \"service/my-key\" }}"
      #   destination   = "local/file.yml"
      #   change_mode   = "signal"
      #   change_signal = "SIGHUP"
      # }

      # The "template" block can also be used to create environment variables
      # for tasks that prefer those to config files. The task will be restarted
      # when data pulled from Consul or Vault changes.
      #
      # template {
      #   data        = "KEY={{ key \"service/my-key\" }}"
      #   destination = "local/file.env"
      #   env         = true
      # }

      # The "vault" block instructs the Nomad client to acquire a token from
      # a HashiCorp Vault server. The Nomad servers must be configured and
      # authorized to communicate with Vault. By default, Nomad will inject
      # The token into the job via an environment variable and make the token
      # available to the "template" block. The Nomad client handles the renewal
      # and revocation of the Vault token.
      #
      # For more information and examples on the "vault" block, please see
      # the online documentation at:
      #
      #     https://developer.hashicorp.com/nomad/docs/job-specification/vault
      #
      # vault {
      #   policies      = ["cdn", "frontend"]
      #   change_mode   = "signal"
      #   change_signal = "SIGHUP"
      # }

      # Controls the timeout between signalling a task it will be killed
      # and killing the task. If not set a default is used.
      # kill_timeout = "20s"
    }
  }
}

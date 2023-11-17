locals {
  helm_chart_timeout=300
  #hpcc_version = "8.6.20"

  owner = {
    name  = var.admin_username
    email = var.aks_admin_email
  }

  owner_name_initials = lower(join("",[for x in split(" ",local.owner.name): substr(x,0,1)]))

  metadata = {
    project             = format("%shpccplatform", local.owner_name_initials)
    product_name        = format("%shpccplatform", local.owner_name_initials)
    business_unit       = "commercial"
    environment         = "sandbox"
    market              = "us"
    product_group        = format("%shpcc", local.owner_name_initials)
    resource_group_type = "app"
    sre_team            = format("%shpccplatform", local.owner_name_initials)
    subscription_type   = "dev"
    additional_tags     = { "justification" = "testing" }
    location            = var.aks_azure_region # Acceptable values: eastus, centralus
  }

  tags = merge(local.metadata.additional_tags, var.extra_tags)

  # # disable_naming_conventions - Disable naming conventions
  # # disable_naming_conventions = true 
  disable_naming_conventions = false
  
  # # auto_launch_eclwatch - Automatically launch ECLWatch web interface.
  #auto_launch_eclwatch = true
  auto_launch_svc = {
    eclwatch = false
  }

  # azure_auth = {
  #   #   AAD_CLIENT_ID     = ""
  #   #   AAD_CLIENT_SECRET = ""
  #   #   AAD_TENANT_ID     = ""
  #   #   AAD_PRINCIPAL_ID  = ""
  #   SUBSCRIPTION_ID = ""
  # }
  
  # hpcc_container = {
  #   version = "9.2.0"
  #   image_name    = "platform-core-ln"
  #   image_root    = "jfrog.com/glb-docker-virtual"
  #   #   custom_chart_version = "9.2.0-rc1"
  #   #   custom_image_version = "9.2.0-demo"
  # }
 
  # hpcc_container_registry_auth = {
  #   username = "value"
  #   password = "value"
  # }
  
  internal_domain = var.aks_dns_zone_name // Example: hpcczone.us-hpccsystems-dev.azure.lnrsg.io
  
  external = {}
  # external = {
  #   blob_nfs = [{
  #     container_id         = ""
  #     container_name       = ""
  #     id                   = ""
  #     resource_group_name  = var.storage_account_resource_group_name
  #     storage_account_id   = ""
  #     storage_account_name = var.storage_account_name
  #   }]
  #   # hpc_cache = [{
  #   #   id     = ""
  #   #   path   = ""
  #   #   server = ""
  #   }]
  #   hpcc = [{
  #     name = ""
  #     planes = list(object({
  #       local  = ""
  #       remote = ""
  #     }))
  #     service = ""
  #   }]
  # }
  
  admin_services_storage_account_settings = {
    replication_type = "ZRS" #LRS only if using HPC Cache
        authorized_ip_ranges = {
          "default" = "0.0.0.0/0" //must be public IP
        }
  
    delete_protection = false
  }
  
  azure_log_analytics_creds = {
    scope     = null
    object_id = "" //AAD_PRINCIPAL_ID
  }
  
  data_storage_config = {
    internal = {
      blob_nfs = {
        data_plane_count = 2
        storage_account_settings = {
          replication_type  = "ZRS"
          delete_protection = false
        }
      }
      # hpc_cache = {
      #   enabled                     = false
      #   size                        = "small"
      #   cache_update_frequency      = "3h"
      #   storage_account_data_planes = null
      # }
    }
    external = null
  }
  

  spill_volumes = {
    spill = {
      name          = "spill"
      size          = 300
      prefix        = "/var/lib/HPCCSystems/spill"
      host_path     = "/mnt"
      storage_class = "spill"
      access_mode   = "ReadWriteOnce"
    }
  }
  
  spray_service_settings = {
    replicas     = 6
    nodeSelector = "spraypool"
  }
  
  # ldap = {
  #   ldap_server = "" //Server IP
  #   dali = {
  #     hpcc_admin_password = ""
  #     hpcc_admin_username = ""
  #     ldap_admin_password = ""
  #     ldap_admin_username = ""
  #     adminGroupName      = "HPCC-Admins"
  #     filesBasedn         = "ou=files,ou=eclHPCCSysUser,dc=z0lpf,dc=onmicrosoft,dc=com"
  #     groupsBasedn        = "OU=AADDC Users,dc=z0lpf,dc=onmicrosoft,dc=com"
  #     resourcesBasedn     = "ou=smc,ou=espservices,ou=eclHPCCSysUser,dc=z0lpf,dc=onmicrosoft,dc=com"
  #     systemBasedn        = "OU=AADDC Users,dc=z0lpf,dc=onmicrosoft,dc=com"
  #     usersBasedn         = "OU=AADDC Users,dc=z0lpf,dc=onmicrosoft,dc=com"
  #     workunitsBasedn     = "ou=workunits,ou=eclHPCCSysUser,dc=z0lpf,dc=onmicrosoft,dc=com"
  #   }
  #   esp = {
  #     hpcc_admin_password = ""
  #     hpcc_admin_username = ""
  #     ldap_admin_password = ""
  #     ldap_admin_username = ""
  #     adminGroupName      = "HPCC-Admins"
  #     filesBasedn         = "ou=files,ou=eclHPCCSysUser,dc=z0lpf,dc=onmicrosoft,dc=com"
  #     groupsBasedn        = "OU=AADDC Users,dc=z0lpf,dc=onmicrosoft,dc=com"
  #     resourcesBasedn     = "ou=smc,ou=espservices,ou=eclHPCCSysUser,dc=z0lpf,dc=onmicrosoft,dc=com"
  #     systemBasedn        = "OU=AADDC Users,dc=z0lpf,dc=onmicrosoft,dc=com"
  #     usersBasedn         = "OU=AADDC Users,dc=z0lpf,dc=onmicrosoft,dc=com"
  #     workunitsBasedn     = "ou=workunits,ou=eclHPCCSysUser,dc=z0lpf,dc=onmicrosoft,dc=com"
  #   }
  # }

  roxie_internal_service = {
    name        = "iroxie"
    servicePort = 9876
    listenQueue = 200
    numThreads  = 30
    visibility  = "local"
    annotations = {}
  }

  roxie_services = [local.roxie_internal_service]

  #========================================
  # defaults in godji original variables.tf
  expose_services = false

  auto_connect = false

  use_existing_vnet = null

  hpcc_enabled = true

  helm_chart_strings_overrides = []

  helm_chart_files_overrides = []

  vault_config = null

  hpcc_container = null

  hpcc_container_registry_auth = null

  roxie_config = [
    {
      disabled                       = (var.aks_enable_roxie == true)? false : true
      name                           = "roxie"
      nodeSelector                   = { workload = "roxiepool" }
      # tlh 20231109 numChannels                    = 2
      numChannels                    = 1
      prefix                         = "roxie"
      replicas                       = 2
      serverReplicas                 = 0
      acePoolSize                    = 6
      actResetLogPeriod              = 0
      affinity                       = 0
      allFilesDynamic                = false
      blindLogging                   = false
      blobCacheMem                   = 0
      callbackRetries                = 3
      callbackTimeout                = 500
      checkCompleted                 = true
      checkFileDate                  = false
      checkPrimaries                 = true
      clusterWidth                   = 1
      copyResources                  = true
      coresPerQuery                  = 0
      crcResources                   = false
      dafilesrvLookupTimeout         = 10000
      debugPermitted                 = true
      defaultConcatPreload           = 0
      defaultFetchPreload            = 0
      defaultFullKeyedJoinPreload    = 0
      defaultHighPriorityTimeLimit   = 0
      defaultHighPriorityTimeWarning = 30000
      defaultKeyedJoinPreload        = 0
      defaultLowPriorityTimeLimit    = 0
      defaultLowPriorityTimeWarning  = 90000
      defaultMemoryLimit             = 1073741824
      defaultParallelJoinPreload     = 0
      defaultPrefetchProjectPreload  = 10
      defaultSLAPriorityTimeLimit    = 0
      defaultSLAPriorityTimeWarning  = 30000
      defaultStripLeadingWhitespace  = false
      diskReadBufferSize             = 65536
      doIbytiDelay                   = true
      egress                         = "engineEgress"
      enableHeartBeat                = false
      enableKeyDiff                  = false
      enableSysLog                   = false
      fastLaneQueue                  = true
      fieldTranslationEnabled        = "payload"
      flushJHtreeCacheOnOOM          = true
      forceStdLog                    = false
      highTimeout                    = 2000
      ignoreMissingFiles             = false
      indexReadChunkSize             = 60000
      initIbytiDelay                 = 10
      jumboFrames                    = false
      lazyOpen                       = true
      leafCacheMem                   = 500
      linuxYield                     = false
      localFilesExpire               = 1
      localSlave                     = false
      logFullQueries                 = false
      logQueueDrop                   = 32
      logQueueLen                    = 512
      lowTimeout                     = 10000
      maxBlockSize                   = 1000000000
      maxHttpConnectionRequests      = 1
      maxLocalFilesOpen              = 4000
      maxLockAttempts                = 5
      maxRemoteFilesOpen             = 100
      memTraceLevel                  = 1
      memTraceSizeLimit              = 0
      memoryStatsInterval            = 60
      minFreeDiskSpace               = 6442450944
      minIbytiDelay                  = 2
      minLocalFilesOpen              = 2000
      minRemoteFilesOpen             = 50
      miscDebugTraceLevel            = 0
      monitorDaliFileServer          = false
      nodeCacheMem                   = 1000
      nodeCachePreload               = false
      parallelAggregate              = 0
      parallelLoadQueries            = 1
      perChannelFlowLimit            = 50
      pingInterval                   = 0
      preabortIndexReadsThreshold    = 100
      preabortKeyedJoinsThreshold    = 100
      preloadOnceData                = true
      prestartSlaveThreads           = false
      remoteFilesExpire              = 3600
      roxieMulticastEnabled          = false
      serverSideCacheSize            = 0
      serverThreads                  = 100
      simpleLocalKeyedJoins          = true
      sinkMode                       = "sequential"
      slaTimeout                     = 2000
      slaveConfig                    = "simple"
      slaveThreads                   = 30
      soapTraceLevel                 = 1
      socketCheckInterval            = 5000
      statsExpiryTime                = 3600
      systemMonitorInterval          = 60000
      totalMemoryLimit               = "5368709120"
      traceLevel                     = 1
      traceRemoteFiles               = false
      trapTooManyActiveQueries       = true
      udpAdjustThreadPriorities      = true
      udpFlowAckTimeout              = 10
      udpFlowSocketsSize             = 33554432
      udpInlineCollation             = true
      udpInlineCollationPacketLimit  = 50
      udpLocalWriteSocketSize        = 16777216
      udpMaxPermitDeadTimeouts       = 100
      udpMaxRetryTimedoutReqs        = 10
      udpMaxSlotsPerClient           = 100
      udpMulticastBufferSize         = 33554432
      udpOutQsPriority               = 5
      udpQueueSize                   = 1000
      udpRecvFlowTimeout             = 2000
      udpRequestToSendAckTimeout     = 500
      udpResendTimeout               = 100
      udpRequestToSendTimeout        = 2000
      udpResendEnabled               = true
      udpRetryBusySenders            = 0
      udpSendCompletedInData         = false
      udpSendQueueSize               = 500
      udpSnifferEnabled              = false
      udpTraceLevel                  = 0
      useAeron                       = false
      useDynamicServers              = false
      useHardLink                    = false
      useLogQueue                    = true
      useMemoryMappedIndexes         = false
      useRemoteResources             = false
      useTreeCopy                    = false
      services                       = local.roxie_services
      topoServer = {
        replicas = 1
      }
      channelResources = {
        cpu    = "1"
        memory = "4G"
      }
    }
  ]
  
  eclagent_settings = {
    hthor = {
      replicas          = 1
      maxActive         = 4
      prefix            = "hthor"
      use_child_process = false
      type              = "hthor"
      spillPlane        = "spill"
      resources = {
        cpu    = "1"
        memory = "4G"
      }
      nodeSelector = { workload = "servpool" }
      egress = "engineEgress"
      cost = {
        perCpu = 1
      }
    },
  }

  eclccserver_settings = {
    "myeclccserver" = {
      useChildProcesses     = false
      maxActive             = 4
      egress                = "engineEgress"
      replicas              = 1
      childProcessTimeLimit = 10
      resources = {
        cpu    = "1"
        memory = "4G"
      }
      nodeSelector = { workload = "servpool" }
      legacySyntax = false
      options      = []
      cost = {
        perCpu = 1
      }
  } }

  dali_settings = {
    coalescer = {
      interval     = 24
      at           = "* * * * *"
      minDeltaSize = 50000
      nodeSelector = { workload = "servpool" }
      resources = {
        cpu    = "1"
        memory = "4G"
      }
    }
    resources = {
      cpu    = "2"
      memory = "8G"
    }
    maxStartupTime = 1200
  }

  dfuserver_settings = {
    maxJobs = 3
    nodeSelector = { workload = "servpool" }
    resources = {
      cpu    = "1"
      memory = "2G"
    }
  }

  sasha_config = {
    disabled = false
    nodeSelector = { workload = "servpool" }
    wu-archiver = {
      disabled = false
      service = {
        servicePort = 8877
      }
      plane           = "sasha"
      interval        = 6
      limit           = 400
      cutoff          = 3
      backup          = 0
      at              = "* * * * *"
      throttle        = 0
      retryinterval   = 6
      keepResultFiles = false
      # egress          = "engineEgress"
    }

    dfuwu-archiver = {
      disabled = false
      service = {
        servicePort = 8877
      }
      plane    = "sasha"
      interval = 24
      limit    = 100
      cutoff   = 14
      at       = "* * * * *"
      throttle = 0
      # egress   = "engineEgress"
    }

    dfurecovery-archiver = {
      disabled = false
      interval = 12
      limit    = 20
      cutoff   = 4
      at       = "* * * * *"
      # egress   = "engineEgress"
    }

    file-expiry = {
      disabled             = false
      interval             = 1
      at                   = "* * * * *"
      persistExpiryDefault = 7
      expiryDefault        = 4
      user                 = "sasha"
      # egress               = "engineEgress"
    }
  }

  ldap_config = null

  ldap_tunables = {
    cacheTimeout                  = 5
    checkScopeScans               = false
    ldapTimeoutSecs               = 131
    maxConnections                = 10
    passwordExpirationWarningDays = 10
    sharedCache                   = true
  }

  install_blob_csi_driver = true

  remote_storage_plane = null

  onprem_lz_settings = {}

  admin_services_node_selector = {}

  thor_config = [{
    disabled            = (var.enable_thor == true) || (var.enable_thor == null)? false : true
    name                = "thor"
    prefix              = "thor"
    numWorkers          = var.thor_num_workers
    keepJobs            = "none"
    maxJobs             = var.thor_max_jobs
    maxGraphs           = 2
    maxGraphStartupTime = 172800
    numWorkersPerPod    = 1
    #nodeSelector        = {}
    nodeSelector        = { workload = "thorpool" }
    egress              = "engineEgress"
    tolerations_value   = "thorpool"
    managerResources = {
      cpu    = 1
      memory = "2G"
    }
    workerResources = {
      cpu    = 3
      memory = "4G"
    }
    workerMemory = {
      query      = "3G"
      thirdParty = "500M"
    }
    eclAgentResources = {
      cpu    = 1
      memory = "2G"
    }
    cost = {
      perCpu = 1
    }
  }]

  admin_services_storage = {
    dali = {
      size = 100
      type = "azurefiles"
    }
    debug = {
      size = 100
      type = "blobnfs"
    }
    dll = {
      size = 100
      type = "blobnfs"
    }
    lz = {
      size = var.storage_lz_gb
      type = "blobnfs"
    }
    sasha = {
      size = 100
      type = "blobnfs"
    }
  }
  #========================================
}

locals {
  thor_worker_cpus = 2

  aks_node_sizes = {
    roxie       = var.aks_roxie_node_size
    serv        = var.aks_serv_node_size
    spray       = var.aks_spray_node_size
    thor        = var.aks_thor_node_size
  }

  ns_spec = {
    "large" = {
       cpu = 2
       ram = 8
    }
    "xlarge" = {
       cpu = 4
       ram = 16
    }
    "2xlarge" = {
       cpu = 8
       ram = 32
    }
    "4xlarge" = {
       cpu = 16
       ram = 64
    }
  }

  twpn = floor("${ local.ns_spec[local.aks_node_sizes.thor].cpu / local.thor_worker_cpus }")
  thorWorkersPerNode = local.twpn > 0? local.twpn : 1

  twr = floor("${local.ns_spec[local.aks_node_sizes.thor].ram / local.thorWorkersPerNode }")
  thor_worker_ram = local.twr > 0? local.twr : 1

  nodesPer1Job = ceil("${var.thor_num_workers /  local.thorWorkersPerNode }")

  thorpool_max_capacity = "${ local.nodesPer1Job * var.thor_max_jobs }"

  helm_chart_timeout=300

  owner = {
    name  = var.admin_username
    email = var.aks_admin_email
  }

  owner_name_initials = lower(join("",[for x in split(" ",local.owner.name): substr(x,0,1)]))

  disable_naming_conventions = false
  
  auto_launch_svc = {
    eclwatch = false
  }

  internal_domain = var.aks_dns_zone_name // Example: hpcczone.us-hpccsystems-dev.azure.lnrsg.io
  
  
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
    replicas     = 1
    nodeSelector = var.aks_4nodepools? "spraypool" : "hpccpool"
  }

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
      nodeSelector                   = var.aks_4nodepools? { workload = "roxiepool" } : { workload = "hpccpool" }
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
      nodeSelector = var.aks_4nodepools? { workload = "servpool" } : { workload = "hpccpool" }
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
      nodeSelector = var.aks_4nodepools? { workload = "servpool" } : { workload = "hpccpool" }
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
      nodeSelector = var.aks_4nodepools? { workload = "servpool" } : { workload = "hpccpool" }
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
    nodeSelector = var.aks_4nodepools? { workload = "servpool" } : { workload = "hpccpool" }
    resources = {
      cpu    = "1"
      memory = "2G"
    }
  }

  sasha_config = {
    disabled = false
    nodeSelector = var.aks_4nodepools? { workload = "servpool" } : { workload = "hpccpool" }
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
    }

    dfurecovery-archiver = {
      disabled = false
      interval = 12
      limit    = 20
      cutoff   = 4
      at       = "* * * * *"
    }

    file-expiry = {
      disabled             = false
      interval             = 1
      at                   = "* * * * *"
      persistExpiryDefault = 7
      expiryDefault        = 4
      user                 = "sasha"
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
    nodeSelector        = var.aks_4nodepools? { workload = "thorpool" } : { workload = "hpccpool" }
    egress              = "engineEgress"
    tolerations_value   = "thorpool"
    managerResources = {
      cpu    = 1
      memory = "2G"
    }
    workerResources = {
      cpu    = local.thor_worker_cpus
      memory = format("%dG", local.thor_worker_ram)
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

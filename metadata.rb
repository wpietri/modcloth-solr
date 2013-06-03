maintainer       "ModCloth, Inc."
maintainer_email "ops@modcloth.com"
license          "Apache 2.0"
description      "Installs/Configures solr"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

depends "java"
depends "smf"

attribute "solr/users",
  :display_name => "Solr users",
  :description => "Users that are able to manage solr using RBAC.",
  :type => "array",
  :required => "recommended"

attribute "solr/auto_commit/max_docs",
  :display_name => "Solr Auto-commit max documents",
  :description => "Maximum number of document writes to queue before forcing a commit. solr/auto_commit/max_time must also be set for this to take effect.",
  :type => "string",
  :required => "recommended"

attribute "solr/auto_commit/max_time",
  :display_name => "Solr Auto-commit max time",
  :description => "Maximum time (in milliseconds) before queued document writes are committed. solr/auto_commit/max_docs must also be set for this to take effect.",
  :type => "string",
  :required => "recommended"

attribute "solr/smf_path",
  :display_name => "Solr SMF path",
  :description => "PATH variable to set for operations in SMF",
  :type => "string",
  :required => "optional"

attribute "solr/use_sunspot",
  :display_name => "Use sunspot schema.xml",
  :description => "Use conf/schema.xml from Sunspot gem. Defaults to true.",
  :required => "optional"

attribute "solr/master/hostname",
  :display_name => "Solr master hostname",
  :description => "Hostname on which solr master runs. Used to configure replication.",
  :type => "string",
  :required => "recommended"

attribute "solr/master/port",
  :display_name => "Solr master port",
  :description => "Port on which solr master runs. Defaults to 9985.",
  :type => "string",
  :required => "optional"

attribute "solr/master/home",
  :display_name => "Solr master home",
  :description => "Directory into which solr home will be installed and configured. Defaults to /opt/solr/master",
  :type => "string",
  :required => "optional"

attribute "solr/replica/port",
  :display_name => "Solr replica port",
  :description => "Port on which solr slave runs. Defaults to 8983.",
  :type => "string",
  :required => "optional"

attribute "solr/replica/home",
  :display_name => "Solr replica home",
  :description => "Directory into which solr home will be installed and configured. Defaults to /opt/solr/replica.",
  :type => "string",
  :required => "optional"

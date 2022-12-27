package = "log-body"
version = "0.1.1-2"

source = {
  url = "git://github.com/zenvia/kong-plugin-http-log-with-body",
  branch = "master"
}

description = {
  summary = "This plugin allows Kong to log body to stderr"
}

dependencies = {
   "uuid >= 0.3"
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.log-body.handler"] = "src/handler.lua",
    ["kong.plugins.log-body.schema"]  = "src/schema.lua",
  }
}
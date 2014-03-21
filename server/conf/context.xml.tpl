<Context docBase="/opt/solr/solr_1.4.0.war" debug="0" crossContext="true">
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

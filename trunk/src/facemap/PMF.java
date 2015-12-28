package facemap;

import java.util.Properties;

import javax.jdo.JDOHelper;
import javax.jdo.PersistenceManagerFactory;

public final class PMF {
	
    private static PersistenceManagerFactory pmfInstance=null;

    private PMF() {}

    public static PersistenceManagerFactory get() {
    	
    	Properties props=new Properties();
		props.put("javax.jdo.PersistenceManagerFactoryClass","org.jpox.PersistenceManagerFactoryImpl");
		props.put("javax.jdo.option.ConnectionDriverName","com.mysql.jdbc.Driver");
		props.put("javax.jdo.option.ConnectionURL","jdbc:mysql://dbinstance.cwhnulsestcs.us-west-1.rds.amazonaws.com:3306/facemapdb");
		props.put("javax.jdo.option.ConnectionUserName","dbmaster");
		props.put("javax.jdo.option.ConnectionPassword","masterpass");
		props.put("javax.jdo.option.NontransactionalRead", "true");
		props.put("org.jpox.autoCreateColumns","true");
		props.put("org.jpox.autoCreateSchema","true");
		props.put("org.jpox.validateTables","false");
		props.put("org.jpox.validateConstraints","false");
		pmfInstance = JDOHelper.getPersistenceManagerFactory(props);
    	
        return pmfInstance;
    }
}

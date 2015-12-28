package facemap;


import java.util.Date;

import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;

import java.text.SimpleDateFormat;

/**
 * Definition of a Landmark
 * Represents a location on the map. 
 **/
@PersistenceCapable
public class Landmark {
   /** 
    * User id
    **/
    protected String userID;
    /** 
     * User id
     **/
     protected String fbID;
    /**
     * Name of the landmark.
     **/
    protected String landmarkName = null;
    /**
     * Address of the landmark.
     **/
    protected String address = null;
    /**
     * Category of the landmark.
     **/
    protected String geocode = null;
    /**
     * Description of the landmark.
     **/
    protected String description = null;
    /**
     * Date when the landmark is added.
     **/
    protected Date dateAdded = null; 
    
    
    /**
     * Default constructor. 
     **/
    protected Landmark() {
    }
    
    /** Constructor.
     */
    public Landmark(String userID, String fbID, String landmarkName, String address, String geocode, String description, Date dateAdded) {
		// TODO Auto-generated constructor stub
		this.userID = userID ;
    	this.fbID = fbID ;
    	this.landmarkName = landmarkName ;
        this.address = address;
        this.geocode = geocode;
        this.description = description;
        this.dateAdded = dateAdded;
		
	}

    // -------------------------Accessors ------------------------
    

	

	public String getUserID() {
		return userID;
	}

	public String getFbID() {
		return fbID;
	}

	public String getLandmarkName() {
		return landmarkName;
	}


	public String getAddress() {
		return address;
	}


	public String getGeocode() {
		return geocode;
	}


	public String getDescription() {
		return description;
	}


	public Date getDateAdded() {
		return dateAdded;
	}
	
	
	public String getDateFormat() {
		
		String dateFormat;
		SimpleDateFormat formatter = new SimpleDateFormat("MMM dd 'at' hh:mm aaa");
	    dateFormat = formatter.format(this.dateAdded);
		return dateFormat;
	}

	// ---------------------------Mutators ----------------------------
	
	public void setUserID(String userID) {
		this.userID = userID;
	}
	

	public void setFbID(String fbID) {
		this.fbID = fbID;
	}


	public void setLandmarkName(String landmarkName) {
		this.landmarkName = landmarkName;
	}


	public void setAddress(String address) {
		this.address = address;
	}


	public void setGeocode(String geocode) {
		this.geocode = geocode;
	}


	public void setDescription(String description) {
		this.description = description;
	}


	public void setDateAdded(Date dateAdded) {
		this.dateAdded = dateAdded;
	} 

    
}

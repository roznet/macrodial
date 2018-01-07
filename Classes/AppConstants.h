/*
 *  AppConstants.h
 *  MacroDial
 *
 *  Created by brice on 10/03/2009.
 *  Copyright 2009 ro-z.net. All rights reserved.
 *
 */

#import "Macros.h"
#define INVALID_ORGANIZER_IDX -1

// States for auto dial view
#define STATE_ORIGINAL_NUMBER 0
#define STATE_MACRO_EXECUTED  1
#define STATE_CUSTOM_EDIT     2


// Tabs index
#define TAB_CONTACT		0
#define TAB_DIAL		1
#define TAB_RECENT		2
#define TAB_CONFIG		3

// Sections for MacroEditView
#define SECTION_NAME		0
#define SECTION_VARIABLE	1
#define SECTION_DEFINITION	2

// Sections for MacroImplview
#define SECTION_TYPE		0
#define SECTION_ARGUMENT	1

// Sections for Config Screen
#define SECTION_MACROS		0
#define SECTION_SETTINGS	1
#define SECTION_DEBUG		2

#define MACROS_SETUP_WIZARD		0
#define MACROS_EDIT_MACROS		1
#define MACROS_WEB				2
#define MACROS_WEB_CODE			3
#define MACROS_WEB_UPLOAD		4
#define MACROS_END				5
#define MACROS_INFO				6

#define DEBUG_INFO				0
#define DEBUG_END				1

#define SETTINGS_HOME_IDD		0
#define SETTINGS_SMS_BUTTON		1
#define SETTINGS_AUTO_EXEC		2
#define SETTINGS_MACRO_SORT		3
#define SETTINGS_MACRO_LEARN	4
#define SETTINGS_INCLUDE_UPLOAD 5
#define SETTINGS_END			6

// Config setting in dictionary
#define CONFIG_AUTOLEARN		@"ConfigAutoLearn"
#define CONFIG_AUTOEXEC			@"AutoExec"
#define CONFIG_SORTLASTUSE		@"ConfigSortUse"
#define CONFIG_SELECTEDTAB		@"selectedtab"
#define CONFIG_FIRST_USE		@"firstuse"
#define CONFIG_SAMPLE_NUMBER	@"samplenumber"
#define CONFIG_INCLUDE_UPLOAD	@"includeupload"
#define CONFIG_LIST_STATUS		@"list_statuses"
#define CONFIG_DB_VERSION		@"db_version"
#define CONFIG_LAST_LATITUDE	@"location_last_latitude"
#define CONFIG_LAST_LONGITUDE	@"location_last_longitude"
#define CONFIG_LAST_LOC_TIME	@"location_last_timestamp"
#define CONFIG_DEFAULT_IDD		@"default_idd"
#define CONFIG_DEBUG			@"debugon"
#define CONFIG_TIP_SHOWN		@"tip_shown"
#define CONFIG_LEFTBUTTON		@"left_button"
#define CONFIG_1_3_FIRSTUSE		@"1_3_first_use"
#define CONFIG_1_5_FIRSTUSE		@"1_5_first_use"

#define LEFTBUTTON_INFO			0
#define LEFTBUTTON_SMS			1


// WIZARD
#define WIZARD_STANDARD_PACKAGES	0
#define WIZARD_OTHER_SETUP			1

#define WIZARD_WEB			0
#define WIZARD_WEB_CODE		1
#define WIZARD_CLEAR_ALL	2
#define WIZARD_END			3

// UPLOAD
#define UPLOAD_SECTION_MACROS	0
#define UPLOAD_SECTION_INFO		1
#define UPLOAD_SECTION_END		2

#define UPLOAD_MACROS_CHOOSE	0
#define UPLOAD_MACROS_HELP  	1
#define UPLOAD_MACROS_END		2

#define UPLOAD_INFO_PACKAGE		0
#define UPLOAD_INFO_CONTACT		1
#define UPLOAD_INFO_DESCRIPTION	2
#define UPLOAD_INFO_UNLOCK		3
#define UPLOAD_INFO_END			4

#define UPLOAD_KEY_CONTACT		@"uploadcontactname"
#define UPLOAD_KEY_PACKAGE		@"uploadpackagename"
#define UPLOAD_KEY_DESCRIPTION	@"uploaddescription"
#define UPLOAD_KEY_UNLOCKCODE	@"uploadunlockcode"

// Record Events
#define RECORDEVENT_LEARNED_NEW			@"Learned new macro"
#define RECORDEVENT_COPIED_MACRO		@"Copied macro"
#define RECORDEVENT_CREATE_NEW_MACRO	@"Created new macro"
#define RECORDEVENT_EDITED_MACRO		@"Edited Macro"
#define RECORDEVENT_EDITED_MACRO10		@"Edited 10 Macro"
#define RECORDEVENT_CALLWEDIT			@"Call w Edit"
#define RECORDEVENT_CALLWORIGINAL		@"Call w Original"
#define RECORDEVENT_CALLWMACRO			@"Call w Macro"
#define RECORDEVENT_CALLWEDIT10			@"10 Call w Edit"
#define RECORDEVENT_CALLWORIGINAL10		@"10 Call w Original"
#define RECORDEVENT_CALLWMACRO10		@"10 Call w Macro"
#define RECORDEVENT_DEBUG				@"Toggle Debug"
#define RECORDEVENT_SMS					@"SMS"
#define RECORDEVENT_SMS10				@"10 SMS"

// YAHOO ZONETAG
#define APPTOKEN @"f29657240e733d83dcf37af89057c32f"
#define LOCATION_UNKNOWN @"Unknown"

// Db info
#define SQLFIELD_COUNTRY @"country_name"
#define SQLFIELD_AREANAME @"area_name"
#define SQLFIELD_AREACODE @"area_code"
#define SQLFIELD_TIMEZONE @"time_zone"
#define SQLFIELD_IDDCODE  @"idd_code"

#define AREA_CODE_MAXSIZE 5


library SOURCE_ID_YEAR version '#'

/*
 * Source:
 * ID:
 * Year:
 * Version:
 * Written By:
 * Reviewed By:
 *
  */

using QDM

// Value Set Source

valueset "Source; Name": 'OID'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator":

define "Denominator Exclusion: ID":
  /*
   * config_link_id: id
   */

define "Numerator Performance Met: ID":
  /*
   * config_link_id: id
   */

 define "Denominator Exception: ID":
   /*
    * config_link_id: id
    */

define "Numerator Performance Not Met: ID":
  /*
   * config_link_id: id
   */

define "Numerator Performance Not Met: ID":
  /*
   * config_link_id: id
   */
  not "Denominator Exclusion: ID"
  and not "Numerator Performance Met: ID"
  and not "Denominator Exception: ID"
  and not "Numerator Performance Not Met: ID"

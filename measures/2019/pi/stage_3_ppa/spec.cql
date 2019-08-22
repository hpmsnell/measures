library STAGE_3_PPA_2019 version '1'

/*
 * Source: Stage 3
 * ID: PPA
 * Year: 2019
 * Version: 2
 * Author: Steve Daniels
 *
  */

using Able Health Data Model

parameter "Measurement Period" Interval<DateTime>
parameter "Reporting Provider ID" String

context Patient

define "Denominator Encounter":
  ["Encounter"] E
    where E.start_datetime during "Measurement Period"
      and E.provider_id = "Reporting Provider ID"

define "Portal Access":
  ["System Event"] S
    where S.type ="PORTAL_ACCESS"

define "API Access":
  union ["System Event"] S
    where S.type ="API_ACCESS_OPT_IN"

define "API Opt Out":
  union ["System Event"] S
    where S.type ="API_ACCESS_OPT_OUT"

define "Health Information Provisioning":
  ["System Event"] S
    where S.start_datetime same year as start of "Measurement Period"
      and S.type = "HEALTH_INFORMATION_PROVISIONING"
    with "Denominator Encounter" E
      such that S.encounter_id = E.external_id

define "Valid Health Information Provisioning With Portal Access":
  "Health Information Provisioning" S1
    where S1.stop_datetime 48 hours or less after S1.start_datetime
    with "Portal Access" S2
      such that (
        S1.stop_date during [S2.start_datetime, S2.stop_datetime]
        or 48 hours after S1.start_date during [S2.start_datetime, S2.stop_datetime]
      )

/* Populations */

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  (
    // The patient has at least one health information provisioning event
    // for the encounter where (1) information is available to the patient 48 hours
    // or less after the information is available to the provider
    // and (2) the patient has access to the portal or API at the time
    // that the information is made available to the patient
    (
      exists("Valid Health Information Provisioning With Portal Access" S1
        with "API Access" S2
          such that (
            S1.stop_date during [S2.start_datetime, S2.stop_datetime]
            or 48 hours after S1.start_date during [S2.start_datetime, S2.stop_datetime]
          )
      )
      or (
        exists("Valid Health Information Provisioning With Portal Access")
        and exists("API Opt Out" S
          where S.start_datetime starts before end of "Measurement Period")
    )
    // ...AND none of the other health information provisioning events for the encounter
    // have information madea vailable to the patient more than 4 days
    // after information is made available to the provider
    and not exists("Health Information Provisioning" S
        where S.stop_datetime more than 48 hours after S.start_datetime)
    // ...AND none of the other health information provisioning events for the encounter
    // have no patient portal access at the time that information is made available to the patient
    and not exists("Health Information Provisioning" S1
      without "Portal Access" S2
        such that (
          S1.stop_date during [S2.start_datetime, S2.stop_datetime]
          or 48 hours after S1.start_date during [S2.start_datetime, S2.stop_datetime]
        )
      )
    // ...AND none of the other health information provisioning events for the encounter
    // have no API access at the time that information is made available to the patient
    and (
      not exists("Health Information Provisioning" S1
        without "API" S2
          such that (
            S1.stop_date during [S2.start_datetime, S2.stop_datetime]
            or 48 hours after S1.start_date during [S2.start_datetime, S2.stop_datetime]
          )
      )
      or exists("API Opt Out" S
        where S.start_datetime starts before end of "Measurement Period")
    )
  )
  // OR patient has no health information provisioning events for any encounter
  // during the measurement period
  or not exists(["System Event"] S
    where S.start_datetime same year as start of "Measurement Period"
      and S.type = "HEALTH_INFORMATION_PROVISIONING"
    with ["Encounter"] E
      where S.encounter_id = E.external_id
      and E.start_datetime during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"

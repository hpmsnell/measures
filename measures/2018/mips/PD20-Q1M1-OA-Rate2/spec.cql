library RADNET_PD20-Q1M1-OA_Rate_2_2018 version '5'

/*
 *
 * Source: RadNet
 * ID: PD20-Q1M1-OA
 * Rate: 2
 * Year: 2019
 * Version: 5
 * Written by: Steve Daniels
 *
  */

using QDM

// Custom value sets (Able)

valueset "Able; RadNet Advanced Image Testing Procedure"
valueset "Able; Performance Met: GPD20N1A"
valueset "Able; RadNet Patient Exclusion"
valueset "Able; Denominator Exception: GPD20N1X"
valueset "Able; Denominator Exception: GPD20N1Y"
valueset "Able; Denominator Exception: GPD20N1Z"
valueset "Able; Performance Met: GPD20N2A"
valueset "Able; Performance Not Met: GPD20N2B"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Ordered": "Able; RadNet Advanced Image Testing Procedure"] P1
    where P1.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of P1.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Procedure, Performed": "Able; Performance Met: GPD20N1A"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod

// Populations

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion: GPD20D1B":
  // config_link_id: GPD20D1B
  exists(["Procedure, Performed": "Able; RadNet Patient Exclusion"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: GPD20N1X":
// config_link_id: GPD20N1X
exists("Denominator Procedure" P1
  with ["Procedure, Performed": "Able; Denominator Exception: GPD20N1X"] P2
    such that P.relevantPeriod starts during P1.relevantPeriod)

define "Denominator Exclusion: GPD20N1Y":
// config_link_id: GPD20N1Y
exists("Denominator Procedure" P1
  with ["Procedure, Performed": "Able; Denominator Exception: GPD20N1Y"] P2
    such that P.relevantPeriod starts during P1.relevantPeriod)
or exists("Denominator Procedure" P
  where P.statusReason in ["ACEXEL","ACFINC","ACINPREP","ACINSDENIE","ACLAB","ACNORESPONSE","ACNOSHOW","ACNOTRANS","ACPCMKR","ACPOSPREG","ACPTWK","ACREFABN","ACWGHT","APATRESCH","BREASTHOLD","BRST US NOT NEED","CONTRAINDICATED","LABSOUT","LOSTINFLWUP","METALIMPLANT","MIMMAMMO","NOINVITEUSED","NOLABS","NOPHONE","NOPREP","PORTAL","UNCONTPT"])

define "Denominator Exclusion: GPD20N1Z":
// config_link_id: GPD20N1Z
exists("Denominator Procedure" P1
  with ["Procedure, Performed": "Able; Denominator Exception: GPD20N1Z"] P2
    such that P.relevantPeriod starts during P1.relevantPeriod)
or exists("Denominator Procedure" P
  where P.statusReason in ["ACCLOSE","ACDOWN","ACEMPER","ACEXELINT","ACNONPAR","ACNOPREAUT","ACREFER","ACWEATH","ADWEATH","AUTOCONFIR","DUP","EMR ORDER","EORDER EXPIRED","EORDER INCORRECT","EQUIP","EQUIPDOWN","NOREF","ORDERNOTUSED","OTCCC","OTCD","OTCSP","P4P","REFCNX","SYSTEST","TESTING","UMREVIEW"])

define "Numerator Performance Met: GPD20N2A":
  // config_link_id: GPD20N2A
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD20N2A"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: GPD20N2B":
  // config_link_id: GPD20N2B
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD20N2B"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)
  or exists("Denominator Procedure" P
    where P.statusReason in ["ACOTHR","ACPTSCK","ACRADCX","ACWLKDOUT","CLAUS","CLAUSTRO","PTLATE","PTREF"])

define "Numerator Performance Not Met: Procedure Not Completed":
  // config_link_id: not_completed
  exists("Denominator Procedure" P
    where P.status not in ["Cancelled","Discontinued"])

define "Numerator Data Incomplete":
  // config_link_id: incomplete
  not "Denominator Exclusion: GPD20D1B"
  and not "Denominator Exclusion: GPD20N1X"
  and not "Denominator Exclusion: GPD20N1Y"
  and not "Denominator Exclusion: GPD20N1Z"
  and not "Numerator Performance Met: GPD20N2A"
  and not "Numerator Performance Not Met: GPD20N2B"
  and not "Numerator Performance Not Met: Procedure Not Completed"

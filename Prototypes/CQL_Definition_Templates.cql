CQL Template Prototype - Different scenarios


//Defining a visit with a specific physical exam, checking to ensure the result is not null.

Encounters -------------------------------------------------------------------------------------

1 Specifying multiple encounters that check for the presence of specific
physical exam findings.

define "Outpatient Visit":
  ["Encounter, Performed": "Adult Outpatient Visit"] Encounter
    with ["Diagnosis": "Essential Hypertension"] Diagnosis
      such that Encounter.relevantPeriod overlaps Diagnosis.prevalencePeriod
    with ["Physical Exam, Performed": "Diastolic Blood Pressure"] Diastolic
      such that Encounter.relevantPeriod overlaps Diastolic.relevantPeriod
        and Diastolic.result is not null
    with ["Physical Exam, Performed": "Systolic Blood Pressure"] Systolic
      such that Encounter.relevantPeriod overlaps Systolic.relevantPeriod
        and Systolic.result is not null


2 Specifying multiple encounters covering a sepecific interale during the measurement
period

  define "Valid Encounters":
    (["Encounter, Performed": "Office Visit"]
      union ["Encounter, Performed": "Face-to-Face Interaction"]
      union ["Encounter, Performed": "Preventive Care - Established Office Visit, 0 to 17"]
      union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
      union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]
      union ["Encounter, Performed": "Preventive Care- Initial Office Visit, 0 to 17"]
      union ["Encounter, Performed": "Home Healthcare Services"]
    ) E where Interval[E.admissionDateTime, E.dischargeDateTime] during "Measurement Period"


3. Specifying specific inpatient encounters, with a specific length of stay, that
occur during the measurement period with a patient of specific age range.

define "Encounter Inpatient":
  ["Encounter, Performed": "Encounter Inpatient Valueset"] Encounter
    where Encounter.lengthOfStay <= 120 days
      and Encounter.stopDateTime during "Measurement Period"
      and AgeInYearsAt(Encounter.startDateTime) >= 8
      and AgeInYearsAt(Encounter.sstartDateTime) < 65

4.  Defing a specific patient opulation based on age, sex and whether a specific encounter exists during the measurement period.

define "Initial Population":
  AgeInYearsAt(start of "Measurement Period") >= 51
    and AgeInYearsAt(start of "Measurement Period") < 74
    and exists (["Patient Characteristic Sex": "Female"])
    and exists ("Encounter During Measurement Period")


5.

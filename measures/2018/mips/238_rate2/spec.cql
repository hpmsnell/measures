library MIPS_238Rate2_2017 version '1'

/*
 * Source: MIPS
 * ID: 238 Rate 2
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// ABLE value sets

valueset "ABLE; Methocarbamol":
valueset "ABLE; Estradiol":

// MIPS value sets

valueset "MIPS; MIPS 238 Encounter"
valueset "MIPS; Hospice Service"
valueset "MIPS; Performance Met: G9367"
valueset "MIPS; Performance Not Met: G9368"

// VSAC value sets

valueset "VSAC; Palliative Care": 'urn:oid:2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Acetaminophen / Butalbital": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1317'
valueset "VSAC; Acetaminophen / Butalbital / Caffeine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1363'
valueset "VSAC; Acetaminophen / Butalbital / Caffeine / Codeine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1326'
valueset "VSAC; Acetaminophen / Chlorpheniramine / Dextromethorphan": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1421'
valueset "VSAC; Acetaminophen / Chlorpheniramine / Dextromethorphan / Phenylephrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1310'
valueset "VSAC; Acetaminophen / Chlorpheniramine / Dextromethorphan / Pseudoephedrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1321'
valueset "VSAC; Acetaminophen / Chlorpheniramine / Phenylephrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1328'
valueset "VSAC; Acetaminophen / Chlorpheniramine / Pseudoephedrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1316'
valueset "VSAC; Acetaminophen / Dexbrompheniramine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1405'
valueset "VSAC; Acetaminophen / Dextromethorphan / Diphenhydramine / Phenylephrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1399'
valueset "VSAC; Acetaminophen / Dextromethorphan / Doxylamine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1338'
valueset "VSAC; Acetaminophen / Dextromethorphan / Doxylamine / Phenylephrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1287'
valueset "VSAC; Acetaminophen / Diphenhydramine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1350'
valueset "VSAC; Acetaminophen / Diphenhydramine / Phenylephrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1318'
valueset "VSAC; Amitriptyline  /  Chlordiazepoxide": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1286'
valueset "VSAC; Amitriptyline / Perphenazine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1428'
valueset "VSAC; Amitriptyline Hydrochloride": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1373'
valueset "VSAC; Anti Infectives, other": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1481'
valueset "VSAC; Aspirin / Butalbital / Caffeine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1347'
valueset "VSAC; Aspirin / Caffeine / Orphenadrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1302'
valueset "VSAC; Atropine / Hyoscyamine / Phenobarbital / Scopolamine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1355'
valueset "VSAC; Benztropine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1361'
valueset "VSAC; Brompheniramine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1427'
valueset "VSAC; Brompheniramine / Codeine / Phenylephrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1409'
valueset "VSAC; Brompheniramine / Codeine / Pseudoephedrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1450'
valueset "VSAC; Brompheniramine / Dextromethorphan / Phenylephrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1325'
valueset "VSAC; Brompheniramine / Dextromethorphan / Pseudoephedrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1339'
valueset "VSAC; Brompheniramine / Phenylephrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1327'
valueset "VSAC; Brompheniramine / Pseudoephedrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1332'
valueset "VSAC; Butabarbital": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1402'
valueset "VSAC; Carbinoxamine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1306'
valueset "VSAC; Carisoprodol": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1369'
valueset "VSAC; Chlophedianol / Chlorpheniramine / Phenylephrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1412'
valueset "VSAC; Chlophedianol / Dexchlorpheniramine / Pseudoephedrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1447'
valueset "VSAC; Chlorpheniramine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1352'
valueset "VSAC; Chlorpheniramine / Codeine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1301'
valueset "VSAC; Chlorpheniramine / Dextromethorphan / Phenylephrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1312'
valueset "VSAC; Chlorpheniramine / Dextromethorphan / Pseudoephedrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1337'
valueset "VSAC; Chlorpheniramine / Hydrocodone": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1330'
valueset "VSAC; Chlorpheniramine / Hydrocodone / Pseudoephedrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1299'
valueset "VSAC; Chlorpheniramine / Phenylephrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1343'
valueset "VSAC; Chlorpheniramine / Phenylephrine / Pyrilamine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1309'
valueset "VSAC; Chlorpheniramine / Pseudoephedrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1315'
valueset "VSAC; Chlorpropamide": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1303'
valueset "VSAC; Chlorzoxazone": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1362'
valueset "VSAC; Clemastine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1308'
valueset "VSAC; Clomipramine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1336'
valueset "VSAC; Conjugated Estrogens": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1357'
valueset "VSAC; Conjugated Estrogens / Medroxyprogesterone": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1324'
valueset "VSAC; Cyclobenzaprine Hydrochloride": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1372'
valueset "VSAC; Desiccated Thyroid": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1354'
valueset "VSAC; Dexbrompheniramine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1375'
valueset "VSAC; Dexbrompheniramine / Dextromethorphan / Phenylephrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1426'
valueset "VSAC; Dexbrompheniramine / Pseudoephedrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1430'
valueset "VSAC; Dexbrompheniramine Maleate / Pseudoephedrine Hydrochloride": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1429'
valueset "VSAC; Dexchlorpheniramine / Dextromethorphan / Pseudoephedrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1300'
valueset "VSAC; Dexchlorpheniramine / Pseudoephedrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1425'
valueset "VSAC; Dextromethorphan / Diphenhydramine / Phenylephrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1397'
valueset "VSAC; Dextromethorphan / Doxylamine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1452'
valueset "VSAC; Dienogest / Estradiol Multiphasic": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1398'
valueset "VSAC; Diphenhydramine / Ibuprofen": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1293'
valueset "VSAC; Diphenhydramine / Phenylephrine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1307'
valueset "VSAC; Diphenhydramine Hydrochloride": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1371'
valueset "VSAC; Dipyridamole": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1349'
valueset "VSAC; Disopyramide": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1311'
valueset "VSAC; Drospirenone / Estradiol": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1410'
valueset "VSAC; Esterified Estrogens": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1419'
valueset "VSAC; Esterified Estrogens / Methyltestosterone": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1320'
valueset "VSAC; Estradiol": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1365'
valueset "VSAC; Estradiol / Norethindrone": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1323'
valueset "VSAC; Estropipate": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1319'
valueset "VSAC; Glyburide": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1368'
valueset "VSAC; Glyburide / Metformin": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1360'
valueset "VSAC; Guanfacine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1341'
valueset "VSAC; High Risk Medications for the Elderly": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1253'
valueset "VSAC; High-Risk Medications With Days Supply Criteria": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1254'
valueset "VSAC; Home Healthcare Services": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1016'
valueset "VSAC; Hydrochlorothiazide / Methyldopa": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1414'
valueset "VSAC; Hydroxyzine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1374'
valueset "VSAC; Imipramine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1359'
valueset "VSAC; Indomethacin": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1366'
valueset "VSAC; Isoxsuprine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1422'
valueset "VSAC; Ketorolac Tromethamine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1364'
valueset "VSAC; Megestrol": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1342'
valueset "VSAC; Meperidine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1351'
valueset "VSAC; Meprobamate": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1284'
valueset "VSAC; Metaxalone": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1358'
valueset "VSAC; Methocarbamol": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1370'
valueset "VSAC; Methyldopa": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1331'
valueset "VSAC; Nifedipine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1353'
valueset "VSAC; Nonbenzodiazepine hypnotics": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1480'
valueset "VSAC; Phenobarbital": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1348'
valueset "VSAC; Promethazine Hydrochloride": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1367'
valueset "VSAC; Pseudoephedrine / Triprolidine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1345'
valueset "VSAC; Trihexyphenidyl": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1334'
valueset "VSAC; Trimipramine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1285'
valueset "VSAC; Triprolidine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1408'
valueset "VSAC; List of Single RxNorm Code Concepts for High Risk Drugs for the Elderly": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1272'
valueset "VSAC; Amoxapine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1273'
valueset "VSAC; Atropine / Diphenoxylate": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1274'
valueset "VSAC; Cyproheptadine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1277'
valueset "VSAC; Desipramine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1278'
valueset "VSAC; Dicyclomine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1279'
valueset "VSAC; Dimenhydrinate": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1500'
valueset "VSAC; Hyoscyamine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1501'
valueset "VSAC; Hyoscyamine / Methenamine / Mblue / Phenyl Salicyl": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1503'
valueset "VSAC; Hyoscyamine / Methenamine / Mblue / Phenyl Salicyl / Sodium Biphosphate": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1504'
valueset "VSAC; Hyoscyamine / Methenamine / Mblue / Sodium Biphosphate": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1505'
valueset "VSAC; Meclizine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1506'
valueset "VSAC; Nortriptyline": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1507'
valueset "VSAC; Paroxetine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1508'
valueset "VSAC; Protriptyline": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1509'
valueset "VSAC; Chlorpheniramine / Phenylephrine / Phenyltoloxamine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1453'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 238 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 65
      and E.signingProvider.hasMeasureMembership = true

define "Hospice":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

define function More than 1 Of("Medication List"<"Medication, Order">):
	"Medication" MedOrder_1
		with "Medication" MedOrder_2
			such that MedOrder_1.authorDatetime 1 day or more after MedOrder_2.authorDatetime
				and MedOrder_1.authorDatetime during "Measurement Period"
				and MedOrder_2.authorDatetime during "Measurement Period"
		return MedOrder_1

define function Cumulative Medication Duration("Medication List"<"Medication, Order">):
	Sum((collapse(Medication.relevantPeriod)) CumulativeDosages
			return all duration in days of CumulativeDosages
	)

define "Medication List":
		"More than 1 Of"(["Medication, Order": "Acetaminophen / Butalbital"])
		or "More than 1 Of"(["Medication, Order": "Acetaminophen / Butalbital / Caffeine"])
		or "More than 1 Of"(["Medication, Order": "Acetaminophen / Butalbital / Caffeine / Codeine"])
		or "More than 1 Of"(["Medication, Order": "Acetaminophen / Chlorpheniramine / Dextromethorphan"])
		or "More than 1 Of"(["Medication, Order": "Acetaminophen / Chlorpheniramine / Dextromethorphan / Phenylephrine"])
		or "More than 1 Of"(["Medication, Order": "Acetaminophen / Chlorpheniramine / Dextromethorphan / Pseudoephedrine"])
		or "More than 1 Of"(["Medication, Order": "Acetaminophen / Chlorpheniramine / Phenylephrine"])
		or "More than 1 Of"(["Medication, Order": "Acetaminophen / Chlorpheniramine / Pseudoephedrine"])
		or "More than 1 Of"(["Medication, Order": "Acetaminophen / Dexbrompheniramine"])
		or "More than 1 Of"(["Medication, Order": "Acetaminophen / Dextromethorphan / Diphenhydramine / Phenylephrine"])
		or "More than 1 Of"(["Medication, Order": "Acetaminophen / Dextromethorphan / Doxylamine"])
		or "More than 1 Of"(["Medication, Order": "Acetaminophen / Dextromethorphan / Doxylamine / Phenylephrine"])
		or "More than 1 Of"(["Medication, Order": "Acetaminophen / Diphenhydramine"])
		or "More than 1 Of"(["Medication, Order": "Acetaminophen / Diphenhydramine / Phenylephrine"])
		or "More than 1 Of"(["Medication, Order": "Acetaminophen / Diphenhydramine / Phenylephrine"])
		or "More than 1 Of"(["Medication, Order": "Amitriptyline  /  Chlordiazepoxide"])
		or "More than 1 Of"(["Medication, Order": "Amitriptyline / Perphenazine"])
		or "More than 1 Of"(["Medication, Order": "Amitriptyline Hydrochloride"])
		or "More than 1 Of"(["Medication, Order": "Aspirin / Butalbital / Caffeine"])
		or "More than 1 Of"(["Medication, Order": "Amoxapine"])
		or "More than 1 Of"(["Medication, Order": "Aspirin / Caffeine / Orphenadrine"])
		or "More than 1 Of"(["Medication, Order": "Atropine / Hyoscyamine / Phenobarbital / Scopolamine"])
		or "More than 1 Of"(["Medication, Order": "Atropine / Diphenoxylate"])
		or "More than 1 Of"(["Medication, Order": "Benztropine"])
		or "More than 1 Of"(["Medication, Order": "Brompheniramine"])
		or "More than 1 Of"(["Medication, Order": "Brompheniramine / Codeine / Phenylephrine"])
		or "More than 1 Of"(["Medication, Order": "Brompheniramine / Codeine / Pseudoephedrine"])
		or "More than 1 Of"(["Medication, Order": "Brompheniramine / Dextromethorphan / Phenylephrine"])
		or "More than 1 Of"(["Medication, Order": "Brompheniramine / Dextromethorphan / Pseudoephedrine"])
		or "More than 1 Of"(["Medication, Order": "Brompheniramine / Phenylephrine"])
		or "More than 1 Of"(["Medication, Order": "Brompheniramine / Pseudoephedrine"])
		or "More than 1 Of"(["Medication, Order": "Butabarbital"])
		or "More than 1 Of"(["Medication, Order": "Carbinoxamine"])
		or "More than 1 Of"(["Medication, Order": "Carisoprodol"])
		or "More than 1 Of"(["Medication, Order": "Chlophedianol / Chlorpheniramine / Phenylephrine"])
		or "More than 1 Of"(["Medication, Order": "Chlophedianol / Dexchlorpheniramine / Pseudoephedrine"])
		or "More than 1 Of"(["Medication, Order": "Chlorpheniramine"])
		or "More than 1 Of"(["Medication, Order": "Chlorpheniramine / Codeine"])
		or "More than 1 Of"(["Medication, Order": "Chlorpheniramine / Dextromethorphan / Phenylephrine"])
		or "More than 1 Of"(["Medication, Order": "Chlorpheniramine / Dextromethorphan / Pseudoephedrine"])
		or "More than 1 Of"(["Medication, Order": "Chlorpheniramine / Hydrocodone"])
		or "More than 1 Of"(["Medication, Order": "Chlorpheniramine / Hydrocodone / Pseudoephedrine"])
		or "More than 1 Of"(["Medication, Order": "Chlorpheniramine / Phenylephrine"])
		or "More than 1 Of"(["Medication, Order": "Chlorpheniramine / Phenylephrine / Phenyltoloxamine"])
		or "More than 1 Of"(["Medication, Order": "Chlorpheniramine / Phenylephrine / Pyrilamine"])
		or "More than 1 Of"(["Medication, Order": "Chlorpheniramine / Pseudoephedrine"])
		or "More than 1 Of"(["Medication, Order": "Chlorpropamide"])
		or "More than 1 Of"(["Medication, Order": "Chlorzoxazone"])
		or "More than 1 Of"(["Medication, Order": "Clemastine"])
		or "More than 1 Of"(["Medication, Order": "Clomipramine"])
		or "More than 1 Of"(["Medication, Order": "Conjugated Estrogens"])
		or "More than 1 Of"(["Medication, Order": "Conjugated Estrogens / Medroxyprogesterone"])
		or "More than 1 Of"(["Medication, Order": "Cyclobenzaprine Hydrochloride"])
		or "More than 1 Of"(["Medication, Order": "Cyproheptadine"])
		or "More than 1 Of"(["Medication, Order": "Desiccated Thyroid"])
		or "More than 1 Of"(["Medication, Order": "Desipramine"])
		or "More than 1 Of"(["Medication, Order": "Dexbrompheniramine"])
		or "More than 1 Of"(["Medication, Order": "Dexbrompheniramine / Dextromethorphan / Phenylephrine"])
		or "More than 1 Of"(["Medication, Order": "Dexbrompheniramine / Pseudoephedrine"])
		or "More than 1 Of"(["Medication, Order": "Dexbrompheniramine Maleate / Pseudoephedrine Hydrochloride"])
		or "More than 1 Of"(["Medication, Order": "Dexchlorpheniramine / Dextromethorphan / Pseudoephedrine"])
		or "More than 1 Of"(["Medication, Order": "Dexchlorpheniramine / Pseudoephedrine"])
		or "More than 1 Of"(["Medication, Order": "Dextromethorphan / Diphenhydramine / Phenylephrine"])
		or "More than 1 Of"(["Medication, Order": "Dextromethorphan / Doxylamine"])
		or "More than 1 Of"(["Medication, Order": "Dicyclomine"])
		or "More than 1 Of"(["Medication, Order": "Dienogest / Estradiol Multiphasic"])
		or "More than 1 Of"(["Medication, Order": "Dimenhydrinate"])
		or "More than 1 Of"(["Medication, Order": "Diphenhydramine / Ibuprofen"])
		or "More than 1 Of"(["Medication, Order": "Diphenhydramine / Phenylephrine"])
		or "More than 1 Of"(["Medication, Order": "Diphenhydramine Hydrochloride"])
		or "More than 1 Of"(["Medication, Order": "Dipyridamole"])
		or "More than 1 Of"(["Medication, Order": "Disopyramide"])
		or "More than 1 Of"(["Medication, Order": "Drospirenone / Estradiol"])
		or "More than 1 Of"(["Medication, Order": "Esterified Estrogens"])
		or "More than 1 Of"(["Medication, Order": "Esterified Estrogens / Methyltestosterone"])
		or "More than 1 Of"(["Medication, Order": "Estradiol"])
		or "More than 1 Of"(["Medication, Order": "Estradiol / Norethindrone"])
		or "More than 1 Of"(["Medication, Order": "Estropipate"])
		or "More than 1 Of"(["Medication, Order": "Glyburide"])
		or "More than 1 Of"(["Medication, Order": "Glyburide / Metformin"])
		or "More than 1 Of"(["Medication, Order": "Guanfacine"])
		or "More than 1 Of"(["Medication, Order": "Hydrochlorothiazide / Methyldopa"])
		or "More than 1 Of"(["Medication, Order": "Hydroxyzine"])
		or "More than 1 Of"(["Medication, Order": "Hyoscyamine"])
		or "More than 1 Of"(["Medication, Order": "Hyoscyamine / Methenamine / Mblue / Phenyl Salicyl"])
		or "More than 1 Of"(["Medication, Order": "Hyoscyamine / Methenamine / Mblue / Phenyl Salicyl / Sodium Biphosphate"])
		or "More than 1 Of"(["Medication, Order": "Hyoscyamine / Methenamine / Mblue / Sodium Biphosphate"])
		or "More than 1 Of"(["Medication, Order": "Imipramine"])
		or "More than 1 Of"(["Medication, Order": "Indomethacin"])
		or "More than 1 Of"(["Medication, Order": "Isoxsuprine"])
		or "More than 1 Of"(["Medication, Order": "Ketorolac Tromethamine"])
		or "More than 1 Of"(["Medication, Order": "Meclizine"])
		or "More than 1 Of"(["Medication, Order": "Megestrol"])
		or "More than 1 Of"(["Medication, Order": "Meperidine"])
		or "More than 1 Of"(["Medication, Order": "Meprobamate"])
		or "More than 1 Of"(["Medication, Order": "Metaxalone"])
		or "More than 1 Of"(["Medication, Order": "Methocarbamol"])
		or "More than 1 Of"(["Medication, Order": "Methyldopa"])
		or "More than 1 Of"(["Medication, Order": "Nifedipine"])
		or "More than 1 Of"(["Medication, Order": "Nortriptyline"])
		or "More than 1 Of"(["Medication, Order": "Paroxetine"])
		or "More than 1 Of"(["Medication, Order": "Phenobarbital"])
		or "More than 1 Of"(["Medication, Order": "Promethazine Hydrochloride"])
		or "More than 1 Of"(["Medication, Order": "Protriptyline"])
		or "More than 1 Of"(["Medication, Order": "Pseudoephedrine / Triprolidine"])
		or "More than 1 Of"(["Medication, Order": "Trihexyphenidyl"])
		or "More than 1 Of"(["Medication, Order": "Trimipramine"])
		or "More than 1 Of"(["Medication, Order": "Triprolidine"])

define "Nonbenzodiazepine_Hypnotics":
	//Nonbenzodiazepine hypnotics
	exists ( "More than 1 Of"(["Medication, Order": "Nonbenzodiazepine hypnotics"]))

define "AntiInfectives":
	//Anti Infectives, other
	exists ( "More than 1 Of"(["Medication, Order": "Anti Infectives, other"]))

define "AntiInfectives During Measurement Period":
	["Medication, Order": "Anti Infectives, other"] AntiInfectives
		where AntiInfectives.relevantPeriod during "Measurement Period"

define "Hypnotics During Measurement Period":
	["Medication, Order": "Nonbenzodiazepine hypnotics"] Hypnotics
		where Hypnotics.relevantPeriod during "Measurement Period"

define "Two High Risk Medications With Prolonged Duration":
  ( "Cumulative Medication Duration"("AntiInfectives During Measurement Period")>= 90
    and "AntiInfectives"
	)
	or ( "Cumulative Medication Duration"("Hypnotics During Measurement Period")>= 90
    and "Nonbenzodiazepine_Hypnotics"
	)

/* Populations */

define "Denominator":
	exists("Denominator Encounter")

define "Denominator Exclusion":
  exists("Hospice" E
    where E.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: G9367":
	exists ( "Medication List" )
		or ( "Two High Risk Medications With Prolonged Duration" )
    or exists(["Procedure, Performed": "MIPS; Performance Met: G9367"] P
      where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G9368":
	not "Denominator Exclusion"
  and not "Numerator Performance Met: G9367"

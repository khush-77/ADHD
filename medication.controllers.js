import MedicationModel from "../models/medication.model.js";
import asyncHandler from "../middlewares/asynchandler.middleware.js";
import APIResponse from "../utils/apiResponse.js";
import APIError from "../utils/apiError.js";

const addMedication = asyncHandler(async (req, res) => {
  const { medicationName, dosage, timeOfTheDay, date,effects } = req.body;

  if (
    !medicationName ||
    !dosage ||
    !timeOfTheDay ||
    !effects ||
    effects.length === 0
  ) {
    throw new APIError(
      "All fields are required, and effects cannot be empty.",
      400
    );
  }
  const dateToAdd= new Date(date);

  const newMedication = new MedicationModel({
    user_id: req.user._id,
    medicationName,
    dosage,
    timeOfTheDay,
    date: dateToAdd,
    effects,
  });

  await newMedication.save();

  return res
    .status(201)
    .json(new APIResponse(201, "Medication added successfully."));
});

const getMedicationByDate = asyncHandler(async (req, res) => {
  const { date } = req.query;
  if (!date) {
    throw new APIError("Date is required.", 400);
  }
  const selectedDate = new Date(date);
  const filter = {
    user_id: req.user._id,
    date: selectedDate, 
  };
  const medications = await MedicationModel.find(filter).select("medicationName dosage timeOfTheDay effects");
  if (!medications.length) {
    return res.status(200).json(new APIResponse(200, "No medications found for the specified user and date.", []));
  }
  return res.status(200).json(new APIResponse(200, "Medications fetched successfully.", medications));
});

export { addMedication, getMedicationByDate };

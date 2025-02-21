import SymptomModel from "../models/symptoms.model.js";
import asyncHandler from "../middlewares/asynchandler.middleware.js";
import APIResponse from "../utils/apiResponse.js";
import APIError from "../utils/apiError.js";

const storeSymptoms = asyncHandler(async (req, res) => {
  const { symptoms, date, severity, timeOfDay, notes } = req.body;

  if (!symptoms || symptoms.length === 0) {
    throw new APIError("Symptoms array cannot be empty.", 400);
  }

  const newSymptom = new SymptomModel({
    user_id: req.user._id,
    symptoms,
    date,
    severity,
    timeOfDay,
    notes,
  });

  await newSymptom.save();

  return res
    .status(201)
    .json(new APIResponse(201, "Symptoms stored successfully."));
});

const getSymptomsByDateAndSeverity = asyncHandler(async (req, res) => {
  const { startDate, endDate} = req.query;

  if (!startDate || !endDate) {
    throw new APIError("Start date and end date are required.", 400);
  }

  const filter = {
    user_id: req.user._id,
    date: {
      $gte: new Date(startDate),
      $lte: new Date(endDate),
    },
  };

  const symptoms = await SymptomModel.find(filter).sort({ date: 1 });
  
  if (!symptoms.length) {
    console.log("No symptoms found for the specified date range.");
    return res
      .status(200)
      .json(
        new APIResponse(
          200,
          "No symptoms found in the specified range",
          symptoms
        )
      );
  }

  return res
    .status(200)
    .json(new APIResponse(200, "Symptoms fetched successfully.", symptoms));
});

export { storeSymptoms, getSymptomsByDateAndSeverity };

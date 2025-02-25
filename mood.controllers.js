import { Mood } from "../models/mood.model.js";
import asyncHandler from "../middlewares/asynchandler.middleware.js";
import APIResponse from "../utils/apiResponse.js";
import APIError from "../utils/apiError.js";

const addMood = asyncHandler(async (req, res) => {
  const { mood, date } = req.body;

  if (!mood || !date) {
    throw new APIError("Mood and date are required fields.", 400);
  }

  // Validate mood range
  if (mood < 1 || mood > 3) {
    throw new APIError("Mood must be between 1 and 3.", 400);
  }

  const user_id = req.user._id;

  try {
    // Check if a mood entry already exists for the given date and user
    let existingMood = await Mood.findOne({ user_id, date });

    if (existingMood) {
      // Update the existing mood entry
      existingMood.mood = mood;
      await existingMood.save();
      return res
        .status(200)
        .json(new APIResponse(200, "Mood updated successfully"));
    } else {
      // Create a new mood entry
      const newMood = new Mood({
        mood,
        date,
        user_id,
      });

      await newMood.save();
      return res
        .status(200)
        .json(new APIResponse(200, "Mood added successfully"));
    }
  } catch (error) {
    throw new APIError("Failed to process mood", 500);
  }
});

const getMoods = asyncHandler(async (req, res) => {
  const { startDate, endDate } = req.query;

  // Convert the startDate and endDate from the query string
  const start = new Date(startDate);
  const end = new Date(endDate);

  // Check if the dates are valid
  if (isNaN(start.getTime()) || isNaN(end.getTime())) {
    console.error("Invalid date format received:", { startDate, endDate });
    throw new APIError("Invalid date format", 400);
  }

  // Fetch moods within the date range for the logged-in user
  const moods = await Mood.find({
    user_id: req.user._id,
    date: {
      $gte: start,
      $lte: end,
    },
  });

  // If no moods are found, return 204 No Content
  if (!moods.length) {
    console.log("No moods found for the given date range.");
    return res
      .status(200)
      .json(
        new APIResponse(200, "No moods found in the specified range", moods)
      );
  }

  // If moods are found, return them in the response
  return res
    .status(200)
    .json(new APIResponse(200, "Moods fetched successfully", moods));
});

export { addMood, getMoods };

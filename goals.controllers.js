import Goal from "../models/goals.model.js";
import asyncHandler from "../middlewares/asynchandler.middleware.js";
import APIResponse from "../utils/apiResponse.js";
import APIError from "../utils/apiError.js";

const addGoal = asyncHandler(async (req, res) => {
  const { goalName, frequency, howOften, notes, startDate } = req.body;

  if (!goalName || !frequency || !howOften || !startDate) {
    throw new APIError(
      "All fields (goalName, frequency, howOften, startDate, progress) are required.",
      400
    );
  }

  const newGoal = new Goal({
    goalName,
    frequency,
    howOften,
    notes,
    startDate,
    user_id: req.user._id, // Link goal to the user
  });

  await newGoal.save();

  return res.status(201).json(new APIResponse(201, "Goal added successfully."));
});

const getGoals = asyncHandler(async (req, res) => {
  const { completed } = req.query; // Filter goals based on completion status

  let filter = { user_id: req.user._id }; // Fetch goals for the logged-in user
  if (completed !== undefined) {
    filter.completed = completed.toLowerCase() === "true"; // Convert query string to boolean
  }

  const goals = await Goal.find(filter);

  return res
    .status(200)
    .json(
      new APIResponse(
        200,
        goals.length ? "Goals fetched successfully" : "No goals found.",
        goals
      )
    );
});

const updateGoalProgress = asyncHandler(async (req, res) => {
  const { goalId } = req.params;
  const { progress } = req.body;

  if (progress === undefined) {
    throw new APIError("Progress value is required.", 400);
  }

  // Find goal by ID and ensure it belongs to the logged-in user
  const goal = await Goal.findOne({ _id: goalId, user_id: req.user._id });

  if (!goal) {
    throw new APIError("Goal not found.", 400);
  }

  // Update progress and mark completed if progress reaches 100%
  goal.progress = progress;
  if (progress >= 4) {
    goal.completed = true;
  } else {
    goal.completed = false;
  }

  await goal.save();

  return res
    .status(200)
    .json(new APIResponse(200, "Goal progress updated successfully.", goal));
});

export { addGoal, getGoals, updateGoalProgress };

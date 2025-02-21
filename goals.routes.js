import { Router } from "express";
import {
  addGoal,
  getGoals,
  updateGoalProgress,
} from "../controllers/goals.controllers.js";
import { auth as authMiddleware } from "../middlewares/auth.middleware.js";

const router = Router();

router.post("/addgoal", authMiddleware, addGoal); // Add a new goal
router.get("/getgoals", authMiddleware, getGoals); // Fetch goals (completed & incomplete)
router.patch("/update-progress/:goalId", authMiddleware, updateGoalProgress);

export default router;

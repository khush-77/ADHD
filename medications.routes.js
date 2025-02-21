import { Router } from "express";
import { addMedication , getMedicationByDate} from "../controllers/medication.controllers.js";
import {auth as authMiddleware} from "../middlewares/auth.middleware.js";

const router = Router();

router.post("/addmedication", authMiddleware, addMedication);
router.route("/getmedication").get(authMiddleware, getMedicationByDate);

export default router;

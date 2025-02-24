import APIError from "../utils/apiError.js";
import asynchandler from "./asynchandler.middleware.js";
import jwt from "jsonwebtoken";

const auth = asynchandler(async (req, res, next) => {
  const token = req.headers.authorization.split(" ")[1];
  let isValid;
  try {
    isValid = await jwt.verify(token, process.env.ACCESSTOKENKEY);
  } catch (error) {
    throw new APIError("session expired", 404);
  }
  req.user = isValid;
  next();
});

export { auth };

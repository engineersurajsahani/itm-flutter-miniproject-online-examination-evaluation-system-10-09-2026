const express=require('express');
const Result=require('../models/Result');

const router=express.Router();

// Get analytics for a specific exam
router.get('/exam/:examId',async (request,response)=>{
    try {
        const analytics=await Result.getExamAnalytics(request.params.examId);
        response.status(200).json(analytics);
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

// Get all results for a specific student
router.get('/student/:studentId',async (request,response)=>{
    try {
        const results=await Result.getStudentResults(request.params.studentId);
        response.status(200).json(results);
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

module.exports=router;

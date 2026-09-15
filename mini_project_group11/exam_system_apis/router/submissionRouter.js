const express=require('express');
const Submission=require('../models/Submission');

const router=express.Router();

// Get all submissions
router.get('/',async (request,response)=>{
    try {
        const submissions=await Submission.find();
        response.status(200).json(submissions);
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

// Get submissions by exam id
router.get('/exam/:examId',async (request,response)=>{
    try {
        const submissions=await Submission.findByExamId(request.params.examId);
        response.status(200).json(submissions);
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

// Get submissions by student id
router.get('/student/:studentId',async (request,response)=>{
    try {
        const submissions=await Submission.findByStudentId(request.params.studentId);
        response.status(200).json(submissions);
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

// Get submission by id
router.get('/:id',async (request,response)=>{
    try {
        const submission=await Submission.findById(request.params.id);
        if(!submission){
            return response.status(404).json({message:"Submission Not Found!!!"});
        }
        response.status(200).json(submission);
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

// Submit exam answers and auto-evaluate
router.post('/',async (request,response)=>{
    try {
        const submission=await Submission.createAndEvaluate(request.body);
        response.status(201).json({message:"Exam Submitted & Evaluated Successfully!!!",submission});
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

// Delete submission
router.delete('/:id',async (request,response)=>{
    try {
        const submission= await Submission.findByIdAndDelete(request.params.id);
        if(!submission){
            return response.status(404).json({message:"Submission Not Found!!!"});
        }
        response.status(200).json({message:"Submission Deleted Successfully!!!",submission});
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

module.exports=router;

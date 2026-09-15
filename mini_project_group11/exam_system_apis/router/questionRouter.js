const express=require('express');
const Question=require('../models/Question');

const router=express.Router();

// Get all questions
router.get('/',async (request,response)=>{
    try {
        const questions=await Question.find();
        response.status(200).json(questions);
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

// Get questions by exam id
router.get('/exam/:examId',async (request,response)=>{
    try {
        const questions=await Question.findByExamId(request.params.examId);
        response.status(200).json(questions);
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

// Get question by id
router.get('/:id',async (request,response)=>{
    try {
        const question=await Question.findById(request.params.id);
        if(!question){
            return response.status(404).json({message:"Question Not Found!!!"});
        }
        response.status(200).json(question);
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

// Create question
router.post('/',async (request,response)=>{
    try {
        const question=await Question.create(request.body);
        response.status(201).json({message:"Question Created Successfully!!!",question});
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

// Update question
router.put('/:id',async (request,response)=>{
    try {
        const question= await Question.findByIdAndUpdate(request.params.id,request.body);
        if(!question){
            return response.status(404).json({message:"Question Not Found!!!"});
        }
        response.status(200).json({message:"Question Updated Successfully!!!",question});
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

// Delete question
router.delete('/:id',async (request,response)=>{
    try {
        const question= await Question.findByIdAndDelete(request.params.id);
        if(!question){
            return response.status(404).json({message:"Question Not Found!!!"});
        }
        response.status(200).json({message:"Question Deleted Successfully!!!",question});
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

module.exports=router;

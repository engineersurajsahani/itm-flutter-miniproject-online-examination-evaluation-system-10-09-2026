const express=require('express');
const Exam=require('../models/Exam');

const router=express.Router();

// Get all exams
router.get('/',async (request,response)=>{
    try {
        const exams=await Exam.find();
        response.status(200).json(exams);
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

// Get exams by status (active/draft/completed)
router.get('/status/:status',async (request,response)=>{
    try {
        const exams=await Exam.findByStatus(request.params.status);
        response.status(200).json(exams);
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

// Get exam by id
router.get('/:id',async (request,response)=>{
    try {
        const exam=await Exam.findById(request.params.id);
        if(!exam){
            return response.status(404).json({message:"Exam Not Found!!!"});
        }
        response.status(200).json(exam);
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

// Create exam
router.post('/',async (request,response)=>{
    try {
        const exam=await Exam.create(request.body);
        response.status(201).json({message:"Exam Created Successfully!!!",exam});
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

// Update exam
router.put('/:id',async (request,response)=>{
    try {
        const exam= await Exam.findByIdAndUpdate(request.params.id,request.body);
        if(!exam){
            return response.status(404).json({message:"Exam Not Found!!!"});
        }
        response.status(200).json({message:"Exam Updated Successfully!!!",exam});
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

// Delete exam
router.delete('/:id',async (request,response)=>{
    try {
        const exam= await Exam.findByIdAndDelete(request.params.id);
        if(!exam){
            return response.status(404).json({message:"Exam Not Found!!!"});
        }
        response.status(200).json({message:"Exam Deleted Successfully!!!",exam});
    } catch (error) {
        response.status(500).json({message:error.message});
    }
});

module.exports=router;

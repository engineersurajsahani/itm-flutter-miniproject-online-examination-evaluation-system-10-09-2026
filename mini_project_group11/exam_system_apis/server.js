const express=require('express');
const userRouter=require('./router/userRouter');
const examRouter=require('./router/examRouter');
const questionRouter=require('./router/questionRouter');
const submissionRouter=require('./router/submissionRouter');
const resultRouter=require('./router/resultRouter');
const db=require('./config/db');
const cors=require('cors');

const app=express();
app.use(cors());
app.use(express.json());
app.use('/users',userRouter);
app.use('/exams',examRouter);
app.use('/questions',questionRouter);
app.use('/submissions',submissionRouter);
app.use('/results',resultRouter);

app.listen(4001, () => {
    console.log(`Exam System Server started on port 4001`);
});

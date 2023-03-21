# Time management app written in flutter

App created by myself for learn flutter and satisfy my need to have an application for effective time management.

I was working without graphic designer so UI of application isn't the best. But application has a lot of implemented features and three types of exercises.

## Categories

Main data type in application is Category. It will be needed to create any exercise.

### Panel where you can add new category:

<img src="https://user-images.githubusercontent.com/57154118/226495218-fdf8d5b7-6781-4c29-ae94-eecf574790f6.jpg"  width="40%">

### Dialog where you can choose an icon for category:

<img src="https://user-images.githubusercontent.com/57154118/226495255-83891068-543d-44f5-8cc2-f584c8a1d540.jpg"  width="40%">

## Types of exercises:

## Shedule exercise

When you have an activity like class or planned activity on some day you can create a shedule exercise which will be visible on interactive calendar (google library).

### Calendar activity:

<img src="https://user-images.githubusercontent.com/57154118/226494708-34aaf403-ac31-42fc-ae1e-3c3b1912ca55.jpg"  width="40%">

### Other possible views of calendar activity:

<img src="https://user-images.githubusercontent.com/57154118/226495671-2d0fbe3e-a6e8-4b5b-ba19-110142d98d10.jpg"  width="40%">

<img src="https://user-images.githubusercontent.com/57154118/226495680-1098ecd7-32cb-4d1d-a193-8844ac96fc08.jpg"  width="40%">

### Activity where you can add shedule exercise:

<img src="https://user-images.githubusercontent.com/57154118/226495923-2ebf3814-978a-4a5b-958b-d36a3950997b.jpg"  width="40%">

## Deadline exercise

When you have an exercise with a planned deadline you can add Deadline Exercise.
Each exercise has a timer to deadline and priority marker (triangle).
There is also a posibility to sort exercises by:
* given priority
* exercise deadline
* by category

<img src="https://user-images.githubusercontent.com/57154118/226496803-259ac803-7e85-4abb-9000-181aed89f7d5.jpg"  width="40%">

### Activity where you can add Deadline exercise

<img src="https://user-images.githubusercontent.com/57154118/226496957-b3fe6cf5-2b2c-4e7f-9ad2-94a388bf73b1.jpg"  width="40%">

## Todo exercise

Last type of exercise is todo (checkbox).
This type is good to use when you have a lot of very similar task. I used this type to mark which tasks/topics/chapters I did, for example, in a given book. There is no limit about deep of level of tasks.

<img src="https://user-images.githubusercontent.com/57154118/226497494-282f98f0-2bf9-4b5c-b343-7f8cbc7f486d.jpg"  width="40%">

<img src="https://user-images.githubusercontent.com/57154118/226497505-4aca969f-a68b-4ff8-b7ed-3204509e225b.jpg"  width="40%">

<img src="https://user-images.githubusercontent.com/57154118/226497513-f36aaa03-ab81-4988-8ca0-a53817009bd8.jpg"  width="40%">

I created a two ways to add todo exercises. 

The first option is to simply add a single task:

<img src="https://user-images.githubusercontent.com/57154118/226498095-84522063-e688-45c1-8e82-cd00c04fddce.jpg"  width="40%">

But when you want to add something like your english book exercise and units are very similar (identical in subunits) you can use a TODO Factory.
This feature was created for such cases. You can create Units with structure:

- Unit 1

-- Vocabulary

-- Speaking

-- Listening

-- Grammar


doing only one adding operation. You enter the name "Unit " in this case and number of tasks so for example 10 (10 Units are in the book). Then you can add subunits which will be copied for rest 9 units. This example on the screen:

<img src="https://user-images.githubusercontent.com/57154118/226498100-58766b22-18f5-4b1f-84bf-08b7025749e0.jpg"  width="40%">

When you want to name your tasks no with number but with letters like: task a), task b) you can enable option is alphabetic.

Yes, I know, this interface is terrible, but I was more interested in implementing as much functionality as possible and did not focus on this aspect. And since I didn't find time later to correct this state of affairs, it stayed that way.

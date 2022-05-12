// 1. номера участков владельцев с отчеством, заканчивающимся на «вна»
db.garden.aggregate([
    {
        $lookup: {
            from: "owner",
            localField: "owners",
            foreignField: "_id",
            as: "owners"
        }
    },
    {
        $match: {
            owners: { $elemMatch: { patronymic: /вна$/ }}
        }
    },
    {
        $project: {
            "_id": 0,
            "number": 1
        }
    }
]);

// 2. участки в том числе общего пользования, на которых зарегистрировано более 1 постройки
db.garden.find({ 'buildingTypes.1': { $exists: true }})

// 3. владелец (владельцы) участка максимальной площади
db.garden.aggregate([
    {
        $lookup: {
            from: "owner",
            localField: "owners",
            foreignField: "_id",
            as: "owners"
        }
    },
    { $unwind: "$owners" },
    {
        $group: {
            _id: null,
            max_area: { $max: "$area" },
            garden_data: {"$push": "$$ROOT"}
        }
    },
    { $unwind: "$garden_data" },
    {
        $project: {
            _id: 0,
            "firstName": "$garden_data.owners.firstName",
            "secondName": "$garden_data.owners.secondName",
            "patronymic": "$garden_data.owners.patronymic",
            max_area: 1,
            "is_eq": {$eq: ["$garden_data.area", "$max_area"]},
        }
    },
    { $match: {"is_eq": true} }
]);

db.garden.aggregate([
    {
        $lookup: {
            from: "owner",
            localField: "owners",
            foreignField: "_id",
            as: "owners"
        }
    },
    {
        $sort: {
            area: -1
        }
    },
    {
        $project: {
            "_id": 0,
            "owners.firstName": 1,
            "owners.secondName": 1
        }
    },
    { $limit : 1 }
]);

// 4. владельцы максимального количества участков
db.owner.aggregate([
    {
        $project: {
            firstName: "$firstName",
            secondName: "$secondName",
            patronymic: "$patronymic",
            gardens_count: { $max: { $size: "$gardens" } },
        }
    },
    {
        $group: {
            _id: null,
            max_gardens_count: {$max: "$gardens_count"},
            owner_data: {"$push": "$$ROOT"}
        }
    },
    { $unwind: "$owner_data" },
    {
        $project: {
            "_id": "$owner_data._id",
            "firstName": "$owner_data.firstName",
            "secondName": "$owner_data.secondName",
            "patronymic": "$owner_data.patronymic",
            max_gardens_count: 1,
            "is_eq": {$eq: ["$owner_data.gardens_count", "$max_gardens_count"]}
        }
    },
    { $match: {"is_eq": true} }
]);

db.owner.aggregate([
    {
        $project: {
            firstName: "$firstName",
            secondName: "$secondName",
            patronymic: "$patronymic",
            max_gardens_count: { $max: { $size: "$gardens" } }
        }
    },
    {
        $sort: {
            max_gardens_count: -1
        }
    },
    {
        $project: {
            _id: 0,
            max_gardens_count: 0
        }
    },
    {
        $limit : 1
    }
]);

db.owner.aggregate([
    {
        $group: {
            _id: { firstName: "$firstName", secondName: "$secondName" },
            max_gardens_count: { $max: { $size: "$gardens" } },
        }
    },
    {
        $sort: {
            max_gardens_count: -1
        }
    },
    {
        $project: {
            "id": 1,
            "max_gardens_count": 1
        }
    },
    {
        $limit : 1
    }
]);

// 5. участки, на которых нет бань
db.garden.aggregate([
    {
        $lookup: {
            from: "buildingType",
            localField: "buildingTypes",
            foreignField: "_id",
            as: "buildingTypes"
        }
    },
    {
        $match: {
            "buildingTypes.name": { $ne: "Баня" }
        }
    },
    {
        $project: {
            "_id": 0,
            "number": 1,
        }
    }
]);

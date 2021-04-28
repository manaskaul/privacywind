const express = require('express');
const app = express();
const mongoose = require('mongoose');
var gplay = require('google-play-scraper');

const port = process.env.PORT || 5000;
require('dotenv').config();

const App = require('./models/App');

app.use(express.json());

app.get('/api/search/:searchTerm', (req, res) => {
	console.log(req.body.search)
	gplay
		.search({
			term: req.params.searchTerm,
			num: 10,
		})
		.then((documents) => {
			//console.log(documents);
			res.status(200).json(documents)
		});
	
})

app.get('/api/permission/:appId', (req, res) => {
	gplay.permissions({ appId: req.params.appId }).then((documents) => {
		//console.log(documents);
		var perm = [];
		var allowedList = ['Camera', 'Contacts', 'Location', 'Microphone', 'Phone', 'SMS', 'Storage'];
		for (var document of documents) {
			if (allowedList.includes(document.type)) {
				perm.push(document.type);	
			}
		}
		var unique = perm.filter((v, i, a) => a.indexOf(v) === i);
		
		res.status(200).json(unique);
	});
});

app.get('/api/similiar/:appId', (req, res) => {
	gplay.similar({ appId: req.params.appId}).then((documents) => {
		console.log(documents.length);
		//console.log(documents);
		res.status(200).json(documents)
	});
});

app.get('/api/categories', (req, res) => {
	gplay.categories().then((documents) => {
		//console.log(documents);
		res.status(200).json(documents);
	});
});

app.get('/api/list/:name', (req, res) => {
	gplay.list({
			category: req.params.name,
			num: 50,
		})
		.then((documents) => {
			res.status(200).json(documents);
		});

})

app.post('/api/updateRating', async(req, res) => {
	var List = req.body.values;

	for (let i = 0; i < List.length; i++) {
		
		item = List[i];

		//item has appID, permission , coefficient
		var entry = item.nameValuePairs;
		await App.findOne({ appID: entry.appID }).then(async (document) => {
			if (document === null) {
				var new_app = new App({
					appID: entry.appID,
				});

				var permission = [
					{
						name: 'Camera',
						coefficient: 1,
					},
					{
						name: 'Microphone',
						coefficient: 1,
					},
					{
						name: 'Location',
						coefficient: 1,
					},
				];

				var foundIndex = permission.findIndex(
					(x) => x.name == entry.permission,
				);
				permission[foundIndex].coefficient = Math.min(
					permission[foundIndex].coefficient,
					entry.coefficient,
				);

				var rating = 0;
				for (perm of permission) {
					if (perm.coefficient == 1) {
						rating += 3.33;
					} else if (perm.coefficient == 0) {
						rating += 1.33;
					}
				}
				new_app['permission'] = permission;
				new_app['rating'] = rating;

				console.log(new_app);

				const result = await new_app.save();

			} else {
				var permission = document.permission;
				var foundIndex = permission.findIndex(
					(x) => x.name == entry.permission,
				);
				if (permission[foundIndex].coefficient > entry.coefficient) {
					permission[foundIndex].coefficient = entry.coefficient;
					var rating = 0;
					for (perm of permission) {
						if (perm.coefficient == 1) {
							rating += 3.33;
						} else if (perm.coefficient == 0) {
							rating += 1.33;
						}
					}

					const result = await App.updateOne(
						{ appID: entry.appID },
						{
							$set: {
								permission: permission,
								rating: rating,
							},
						},
					)
				}
			}
		});
	}
	res.status(201).json({});
})

app.get('/api/rating/:appID', (req, res) => {
	App.findOne({ appID: req.params.appID })
	.then((document) => {
		res.status(200).json(document);
	})
})

app.get('/api/rating', (req, res) => {
	App.find()
	.then((document) => {
		res.status(200).json(document);
	})
})

mongoose
	.connect(process.env.CONNECTION_STRING, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
	.then(() => {
		console.log('Connected to Database');
	})
	.catch(() => {
		console.log('Connection failed');
	});


app.listen(port, () => {
	console.log(`Server is running on ${port}`);
});

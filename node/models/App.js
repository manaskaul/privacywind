const mongoose = require('mongoose');

const AppSchema = mongoose.Schema({
	appID: String,
	permission: [
		{
			_id: false,
			name: String,
			coefficient: Number,
		},
	],
	rating: Number,
});

module.exports = mongoose.model('App', AppSchema);

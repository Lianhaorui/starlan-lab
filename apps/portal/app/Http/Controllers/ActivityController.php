<?php

namespace App\Http\Controllers;

use App\Activity;
use App\Registration;
use Illuminate\Http\Request;

class ActivityController extends Controller
{
    public function index()
    {
        $activities = Activity::orderBy('id')->get();
        return view('home', ['activities' => $activities]);
    }

    public function show($activity)
    {
        $activity = Activity::findOrFail($activity);
        $mine = Registration::where('activity_id', $activity->id)
            ->where('user_id', session('uid'))
            ->first();
        return view('activity', ['activity' => $activity, 'mine' => $mine]);
    }

    public function storeRegistration(Request $request, $activity)
    {
        $activity = Activity::findOrFail($activity);

        $data = $request->validate([
            'real_name' => 'required|string|max:60',
            'idcard' => 'required|string|max:30',
            'phone' => 'required|string|max:30',
        ]);

        $reg = Registration::create([
            'activity_id' => $activity->id,
            'user_id' => session('uid'),
            'real_name' => $data['real_name'],
            'idcard' => $data['idcard'],
            'phone' => $data['phone'],
        ]);

        return redirect('/registration/' . $reg->id);
    }

    public function showRegistration($id)
    {
        $reg = Registration::where('id', $id)->first();
        $activity = $reg ? Activity::find($reg->activity_id) : null;
        return view('registration', ['reg' => $reg, 'activity' => $activity]);
    }
}

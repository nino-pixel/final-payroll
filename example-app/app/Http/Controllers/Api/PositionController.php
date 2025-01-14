<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\PositionRequest;
use App\Models\Position;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class PositionController extends Controller
{
    public function index(Request $request)
    {
        $positions = Position::with('department')
            ->when($request->search, function($query) use ($request) {
                $query->where('title', 'like', "%{$request->search}%");
            })
            ->orderBy($request->sort_by ?? 'title', $request->sort_order ?? 'asc')
            ->paginate($request->per_page ?? 1000);

        return response()->json($positions);
    }

    public function store(PositionRequest $request)
    {
        $position = Position::create($request->validated());
        return response()->json($position, Response::HTTP_CREATED);
    }

    public function show(Position $position)
    {
        return response()->json($position->load('department'));
    }

    public function update(PositionRequest $request, Position $position)
    {
        $position->update($request->validated());
        return response()->json($position);
    }

    public function destroy(Position $position)
    {
        $position->delete();
        return response()->json(null, Response::HTTP_NO_CONTENT);
    }
}
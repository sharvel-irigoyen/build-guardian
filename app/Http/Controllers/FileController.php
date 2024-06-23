<?php

namespace App\Http\Controllers;

use App\Models\File;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class FileController extends Controller
{
    public function index()
    {
        $files = File::where('user_id', Auth::id())->get();
        return response()->json($files);
    }

    public function store(Request $request)
    {
        $request->validate([
            'file' => 'required|file',
        ]);

        $uploadedFile = $request->file('file');
        $fileData = file_get_contents($uploadedFile);

        $file = new File();
        $file->user_id = Auth::id();
        $file->name = $uploadedFile->getClientOriginalName();
        $file->type = $uploadedFile->getClientMimeType();
        $file->data = new \MongoDB\BSON\Binary($fileData, \MongoDB\BSON\Binary::TYPE_GENERIC);
        $file->save();

        // Omitimos el contenido binario en la respuesta JSON
        $responseFile = $file->toArray();
        unset($responseFile['data']);

        return response()->json(['message' => 'File uploaded successfully', 'file' => $responseFile]);
    }

    public function show($id)
    {
        $file = File::findOrFail($id);

        if ($file->user_id !== Auth::id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
        
        return response()->json($file);
    }

    public function update(Request $request, $id)
    {
        $file = File::findOrFail($id);

        if ($file->user_id !== Auth::id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($request->hasFile('file')) {
            $request->validate([
                'file' => 'required|file',
            ]);

            $fileData = file_get_contents($request->file('file'));

            $file->name = $request->file('file')->getClientOriginalName();
            $file->type = $request->file('file')->getClientMimeType();
            $file->data = $fileData;
        }

        $file->save();

        return response()->json(['message' => 'File updated successfully', 'file' => $file]);
    }

    public function destroy($id)
    {
        $file = File::findOrFail($id);

        if ($file->user_id !== Auth::id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $file->delete();

        return response()->json(['message' => 'File deleted successfully']);
    }
}
